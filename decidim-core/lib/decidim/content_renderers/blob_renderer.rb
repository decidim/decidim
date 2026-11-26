# frozen_string_literal: true

module Decidim
  module ContentRenderers
    # A renderer that searches Global IDs representing blobs in content and
    # replaces it with a URL to these blobs.
    #
    # e.g. gid://<APP_NAME>/ActiveStorage::Blob/1
    #
    # OR for representations
    #
    # e.g. gid://<APP_NAME>/ActiveStorage::Blob/1/<encoded variant transformations>
    #
    # The `<encoded variant transformations>` part of the URL is a Base64
    # encoded string that contains an unencrypted JSON-encoded value about the
    # blob transformations. This way the specific representations can be stored
    # in the database without having these values expiring.
    #
    # @see BaseRenderer Examples of how to use a content renderer
    class BlobRenderer < BaseRenderer
      # Matches a global id representing an ActiveStorage::Blob (optionally with a variant key)
      GLOBAL_ID_REGEX = %r{(gid://[\w-]+/ActiveStorage::Blob/\d+)(/([\w=-]+))?(?:[^\s"'<>]*)}

      # Replaces found Global IDs matching an existing blob with a URL to
      # that blob. The Global IDs representing an invalid ActiveStorage::Blob
      # are replaced with an empty string.
      #
      # Blobs attached to records that require private downloads (for example
      # verification documents or private exports) are rendered through the
      # authorized private download endpoint instead of exposing a signed
      # Active Storage URL. Blobs that are not attached to any record, or that
      # belong to another organization when the organization is known, are not
      # rendered at all.
      #
      # @param options [Hash, nil] rendering options. The `:organization`
      #   option is used to scope the rendered blobs to the current tenant.
      # @return [String] the content ready to display (contains HTML)
      def render(options = nil)
        @organization = options.is_a?(Hash) ? options[:organization] : nil
        @organization ||= RequestStore.store[:current_organization] if defined?(RequestStore)

        replace_pattern(content, GLOBAL_ID_REGEX)
      end

      protected

      def replace_pattern(text, pattern)
        replace_pattern_by_context(text, pattern) do |match, _context|
          match_data = match.match(GLOBAL_ID_REGEX)
          blob_gid = match_data[1]
          variation_key = match_data[3]

          blob = GlobalID::Locator.locate(blob_gid)
          render_blob(blob, variation_key)
        end
      end

      def render_blob(blob, variation_key)
        attachments = blob.attachments.to_a
        private_attachment = attachments.find { |attachment| private_attachment?(attachment) }
        return private_download_url(private_attachment) if private_attachment
        return "" unless publicly_renderable?(attachments)

        if variation_key
          variation = begin
            ActiveSupport::JSON.decode(Base64.strict_decode64(variation_key))
          rescue JSON::ParseError
            variation_key
          end
          blob_url(blob, variation)
        else
          blob_url(blob)
        end
      end

      # Whether the attachment must be served through the private download
      # endpoint. This includes verification documents and private exports, as
      # well as attachments in restricted spaces.
      def private_attachment?(attachment)
        record = attachment.record
        record.respond_to?(:private_download_required?) && record.private_download_required?
      end

      # A blob can only be rendered publicly when it is attached to at least
      # one record and, when the current organization is known, all the
      # records using it belong to that organization. Unattached blobs are
      # rejected because they may be uploads that are not yet attached to a
      # record (for example an in-progress verification document).
      def publicly_renderable?(attachments)
        records = attachments.map(&:record).compact
        return false if records.empty?
        return true if @organization.blank?

        records.all? { |record| record_organization(record) == @organization }
      end

      def record_organization(record)
        return record if record.is_a?(Decidim::Organization)
        return unless record.respond_to?(:organization)

        record.organization
      end

      def private_download_url(attachment)
        Decidim::Core::Engine.routes.url_helpers.private_download_path(
          Decidim::PrivateDownload.for(attachment.record, attachment_name: attachment.name).token
        )
      end

      def blob_url(blob, variation = nil)
        url = begin
          if variation
            blob.variant(variation).url
          else
            blob.url
          end
        rescue ArgumentError
          # ArgumentError is raised in case the blob's service is set to
          # ActiveStorage::Service::DiskService and
          # `ActiveStorage::Current.url_options` is not set.
        end
        raise URI::InvalidURIError if url.blank?

        url
      rescue URI::InvalidURIError
        local_blob_url(blob, variation)
      end

      def local_blob_url(blob, variation = nil)
        if variation
          routes.rails_representation_url(blob.variant(variation), only_path: true)
        else
          routes.rails_blob_url(blob, only_path: true)
        end
      end

      def routes
        @routes ||= Rails.application.routes.url_helpers
      end
    end
  end
end

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
      # Matches a global id representing a Decidim::User
      GLOBAL_ID_REGEX = %r{(gid://[\w-]+/ActiveStorage::Blob/\d+)(/([\w=-]+))?}

      # Replaces found Global IDs matching an existing blob with a URL to
      # that blob. The Global IDs representing an invalid ActiveStorage::Blob
      # are replaced with an empty string.
      #
      # @return [String] the content ready to display (contains HTML)
      def render(_options = nil)
        replace_pattern(content, GLOBAL_ID_REGEX)
      end

      protected

      def replace_pattern(text, pattern)
        return text unless text.respond_to?(:gsub)

        text.gsub(pattern) do
          blob_gid = Regexp.last_match(1)
          variation_key = Regexp.last_match(3)

          blob = GlobalID::Locator.locate(blob_gid)
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
        rescue ActiveRecord::RecordNotFound => _e
          ""
        end
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

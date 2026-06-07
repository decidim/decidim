# frozen_string_literal: true

module Decidim
  module Assemblies
    # A factory class to ensure we always create Assemblies the same way since it involves some logic.
    class AssemblyImporter < Decidim::Importers::Importer
      attr_reader :warnings

      def initialize(organization, user)
        @organization = organization
        @user = user
        @warnings = []
      end

      # Public: Creates a new Assembly.
      #
      # attributes  - The Hash of attributes to create the Assembly with.
      # user        - The user that performs the action.
      # opts        - The options MUST contain:
      #   - title: The +title+ for the new Assembly
      #   - slug: The +slug+ for the new Assembly
      #
      # Returns an Assembly instance.
      def import(attributes, _user, opts)
        title = opts[:title]
        slug = opts[:slug]
        Decidim.traceability.perform_action!(:create, Assembly, @user, visibility: "all") do
          @imported_assembly = Assembly.new(
            organization: @organization,
            title:,
            slug:,
            subtitle: attributes["subtitle"],
            short_description: attributes["short_description"],
            description: attributes["description"],
            promoted: attributes["promoted"],
            developer_group: attributes["developer_group"],
            local_area: attributes["local_area"],
            target: attributes["target"],
            participatory_scope: attributes["participatory_scope"],
            participatory_structure: attributes["participatory_structure"],
            reference: attributes["reference"],
            purpose_of_action: attributes["purpose_of_action"],
            composition: attributes["composition"],
            duration: attributes["duration"],
            creation_date: attributes["creation_date"],
            closing_date_reason: attributes["closing_date_reason"],
            included_at: attributes["included_at"],
            closing_date: attributes["closing_date"],
            created_by_other: attributes["created_by_other"],
            internal_organisation: attributes["internal_organisation"],
            special_features: attributes["special_features"],
            twitter_handler: attributes["twitter_handler"],
            instagram_handler: attributes["instagram_handler"],
            facebook_handler: attributes["facebook_handler"],
            youtube_handler: attributes["youtube_handler"],
            github_handler: attributes["github_handler"],
            created_by: attributes["created_by"],
            meta_scope: attributes["meta_scope"],
            access_mode: resolve_access_mode(attributes)
          )
          import_hero_image(attributes["remote_hero_image_url"])
          @imported_assembly.save!
          @imported_assembly
        end
      end

      def import_folders_and_attachments(attachments)
        return if attachments["files"].nil?

        attachments["files"].map do |file|
          url = file["remote_file_url"]
          next if url.blank?

          error = remote_file_error(url)
          if error.present?
            @warnings << I18n.t(
              "decidim.assemblies.admin.imports.attachment_error",
              title: attachment_title(file),
              error:
            )
            next
          end

          Decidim.traceability.perform_action!("create", Attachment, @user) do
            attachment = Attachment.new(
              title: file["title"],
              description: file["description"],
              attached_to: @imported_assembly,
              weight: file["weight"]
            )
            begin
              attachment.attached_uploader(:file).remote_url = url
              attachment.set_content_type_and_size
            rescue OpenURI::HTTPError, Errno::ENOENT, Errno::ECONNREFUSED, SocketError, Net::OpenTimeout, Net::ReadTimeout => e
              @warnings << I18n.t(
                "decidim.assemblies.admin.imports.attachment_error",
                title: attachment_title(file),
                error: format_error(e)
              )
              next
            end
            attachment.create_attachment_collection(file["attachment_collection"])
            attachment.save!
            attachment
          end
        end

        if attachments["attachment_collections"].present?
          attachments["attachment_collections"]&.map do |collection|
            Decidim.traceability.perform_action!("create", AttachmentCollection, @user) do
              create_attachment_collection(collection)
            end
          end
        end
      end

      # +components+: An Array of Hashes, each corresponding with the settings of a Decidim::Component.
      def import_components(components)
        return if components.nil?

        importer = Decidim::Importers::ParticipatorySpaceComponentsImporter.new(@imported_assembly)
        importer.import(components, @user)
      end

      private

      def create_attachment_collection(attributes)
        return unless attributes.compact.any?

        attachment_collection = AttachmentCollection.find_or_initialize_by(
          name: attributes["name"],
          weight: attributes["weight"],
          description: attributes["description"],
          collection_for: @imported_assembly
        )
        attachment_collection.save!
        attachment_collection
      end

      def remote_file_error(url)
        return if url.nil?

        accepted = ["image", "application/pdf"]
        url = URI.parse(url)
        http_connection = Net::HTTP.new(url.host, url.port)
        http_connection.use_ssl = true if url.scheme == "https"
        http_connection.start do |http|
          response = http.head(url.request_uri)
          content_type = response["Content-Type"]
          next if response.is_a?(Net::HTTPSuccess) && content_type&.start_with?(*accepted)

          message = response.message.presence || Rack::Utils::HTTP_STATUS_CODES[response.code.to_i]
          message = message.presence || "Error"
          next "#{response.code} #{message}"
        end
      rescue StandardError => e
        format_error(e)
      end

      def attachment_title(file)
        title = file["title"]
        return "" if title.blank?

        return title unless title.is_a?(Hash)

        title.values.find(&:present?) || ""
      end

      def import_hero_image(url)
        return if url.blank?

        @imported_assembly.attached_uploader(:hero_image).remote_url = url
      rescue OpenURI::HTTPError, Errno::ENOENT, Errno::ECONNREFUSED, SocketError, Net::OpenTimeout, Net::ReadTimeout => e
        @warnings << I18n.t("decidim.assemblies.admin.imports.hero_image_error", error: format_error(e))
      end

      def format_error(error)
        return error.message unless error.respond_to?(:io) && error.io.respond_to?(:status)

        status = error.io.status
        return error.message if status.blank? || status.first.blank?

        code = status[0]
        message = status[1].presence || Rack::Utils::HTTP_STATUS_CODES[code.to_i]
        message = message.presence || error.message
        "#{code} #{message}"
      end

      def resolve_access_mode(attributes)
        return attributes["access_mode"] if attributes["access_mode"].present?

        return "transparent" if attributes["is_transparent"] == true
        return "restricted" if attributes["private_space"] == true

        "open"
      end
    end
  end
end

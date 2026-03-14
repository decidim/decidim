# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A factory class to ensure we always create ParticipatoryProcesses the same way since it involves some logic.
    class ParticipatoryProcessImporter < Decidim::Importers::Importer
      attr_reader :warnings

      def initialize(organization, user)
        @organization = organization
        @user = user
        @warnings = []
      end

      # Public: Creates a new ParticipatoryProcess.
      #
      # attributes  - The Hash of attributes to create the ParticipatoryProcess with.
      # user        - The user that performs the action.
      # opts        - The options MUST contain:
      #   - title: The +title+ for the new ParticipatoryProcess
      #   - slug: The +slug+ for the new ParticipatoryProcess
      #
      # Returns a ParticipatoryProcess.
      def import(attributes, _user, opts)
        title = opts[:title]
        slug = opts[:slug]
        process_group = import_process_group(attributes["participatory_process_group"]) unless attributes["participatory_process_group"].nil?
        Decidim.traceability.perform_action!(:create, ParticipatoryProcess, @user, visibility: "all") do
          @imported_process = ParticipatoryProcess.new(
            organization: @organization,
            title:,
            slug:,
            subtitle: attributes["subtitle"],
            description: attributes["description"],
            short_description: attributes["short_description"],
            promoted: attributes["promoted"],
            developer_group: attributes["developer_group"],
            local_area: attributes["local_area"],
            target: attributes["target"],
            participatory_scope: attributes["participatory_scope"],
            participatory_structure: attributes["participatory_structure"],
            meta_scope: attributes["meta_scope"],
            start_date: attributes["start_date"],
            end_date: attributes["end_date"],
            private_space: attributes["private_space"],
            participatory_process_group: process_group
          )
          import_hero_image(attributes["remote_hero_image_url"])

          @imported_process.save!
          @imported_process
        end
      end

      def import_process_group(attributes)
        title = compact_translation(attributes["title"] || attributes["name"])
        description = compact_translation(attributes["description"])

        return if title.blank? && description.blank?

        Decidim.traceability.perform_action!("create", ParticipatoryProcessGroup, @user) do
          group = ParticipatoryProcessGroup.find_or_initialize_by(
            title: attributes["title"] || attributes["name"],
            description: attributes["description"],
            organization: @organization
          )

          import_group_hero_image(group, attributes["remote_hero_image_url"])
          group.save!
          group
        end
      end

      def import_participatory_process_steps(steps)
        return if steps.nil?

        steps.map do |step_attributes|
          Decidim.traceability.create!(
            ParticipatoryProcessStep,
            @user,
            title: step_attributes["title"],
            description: step_attributes["description"],
            start_date: step_attributes["start_date"],
            end_date: step_attributes["end_date"],
            participatory_process: @imported_process,
            active: step_attributes["active"],
            position: step_attributes["position"]
          )
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
              "decidim.participatory_processes.admin.imports.attachment_error",
              title: attachment_title(file),
              error:
            )
            next
          end

          Decidim.traceability.perform_action!("create", Attachment, @user) do
            attachment = Attachment.new(
              title: file["title"],
              description: file["description"],
              attached_to: @imported_process,
              weight: file["weight"]
            )
            begin
              attachment.attached_uploader(:file).remote_url = url
              attachment.set_content_type_and_size
            rescue OpenURI::HTTPError, Errno::ENOENT, Errno::ECONNREFUSED, SocketError, Net::OpenTimeout, Net::ReadTimeout => e
              @warnings << I18n.t(
                "decidim.participatory_processes.admin.imports.attachment_error",
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

        unless attachments["attachment_collections"].empty?
          attachments["attachment_collections"].map do |collection|
            Decidim.traceability.perform_action!("create", AttachmentCollection, @user) do
              create_attachment_collection(collection)
            end
          end
        end
      end

      # +components+: An Array of Hashes, each corresponding with the settings of a Decidim::Component.
      def import_components(components)
        return if components.nil?

        importer = Decidim::Importers::ParticipatorySpaceComponentsImporter.new(@imported_process)
        importer.import(components, @user)
      end

      private

      def compact_translation(translation)
        translation["machine_translations"] = translation["machine_translations"].compact_blank if translation["machine_translations"].present?
        translation.compact_blank
      end

      def create_attachment_collection(attributes)
        return unless attributes.compact.any?

        attachment_collection = AttachmentCollection.find_or_initialize_by(
          name: attributes["name"],
          weight: attributes["weight"],
          description: attributes["description"],
          collection_for: @imported_process
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

        @imported_process.attached_uploader(:hero_image).remote_url = url
      rescue OpenURI::HTTPError, Errno::ENOENT, Errno::ECONNREFUSED, SocketError, Net::OpenTimeout, Net::ReadTimeout => e
        @warnings << I18n.t("decidim.participatory_processes.admin.imports.hero_image_error", error: format_error(e))
      end

      def import_group_hero_image(group, url)
        return if url.blank?

        group.attached_uploader(:hero_image).remote_url = url
      rescue OpenURI::HTTPError, Errno::ENOENT, Errno::ECONNREFUSED, SocketError, Net::OpenTimeout, Net::ReadTimeout => e
        @warnings << I18n.t("decidim.participatory_processes.admin.imports.hero_image_error", error: format_error(e))
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
    end
  end
end

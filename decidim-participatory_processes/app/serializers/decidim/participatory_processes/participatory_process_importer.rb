# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A factory class to ensure we always create ParticipatoryProcesses the same way since it involves some logic.
    class ParticipatoryProcessImporter < Decidim::Importers::Importer
      def initialize(organization, user)
        @organization = organization
        @user = user
      end

      # Public: Creates a new ParticipatoryProcess.
      #
      # attributes  - The Hash of attributes to create the ParticipatoryProcess with.
      # user        - The user that performs the action.
      # opts        - The options MUST contain:
      #   - title: The +title+ for the new PartidicpatoryProcess
      #   - slug: The +slug+ for the new PartidicpatoryProcess
      #
      # Returns a ParticipatoryProcess.
      def import(attributes, _user, opts)
        title = opts[:title]
        slug = opts[:slug]
        Decidim.traceability.perform_action!(:create, ParticipatoryProcess, @user, visibility: "all") do
          @imported_process = ParticipatoryProcess.new(
            organization: @organization,
            title: title,
            slug: slug,
            subtitle: attributes["subtitle"],
            hashtag: attributes["hashtag"],
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
            announcement: attributes["announcement"],
            private_space: attributes["private_space"],
            scopes_enabled: attributes["scopes_enabled"],
            participatory_process_group: import_process_group(attributes["participatory_process_group"])
          )
          @imported_process.remote_hero_image_url = attributes["remote_hero_image_url"] if remote_file_exists?(attributes["remote_hero_image_url"])
          @imported_process.remote_banner_image_url = attributes["remote_banner_image_url"] if remote_file_exists?(attributes["remote_banner_image_url"])
          @imported_process.save!
          @imported_process
        end
      end

      def import_process_group(attributes)
        Decidim.traceability.perform_action!("create", ParticipatoryProcessGroup, @user) do
          group = ParticipatoryProcessGroup.find_or_initialize_by(
            name: attributes["name"],
            description: attributes["description"],
            organization: @organization
          )

          group.remote_hero_image_url = attributes["remote_hero_image_url"] if remote_file_exists?(attributes["remote_hero_image_url"])
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

      def import_categories(categories)
        return if categories.nil?

        categories.map do |category_attributes|
          category = Decidim.traceability.create!(
            Category,
            @user,
            name: category_attributes["name"],
            description: category_attributes["description"],
            parent_id: category_attributes["parent_id"],
            participatory_space: @imported_process
          )
          next if category_attributes["subcategories"].nil?

          category_attributes["subcategories"].map do |subcategory_attributes|
            Decidim.traceability.create!(
              Category,
              @user,
              name: subcategory_attributes["name"],
              description: subcategory_attributes["description"],
              parent_id: category.id,
              participatory_space: @imported_process
            )
          end
        end
      end

      def import_folders_and_attachments(attachments)
        return if attachments["files"].nil?

        attachments["files"].map do |file|
          next unless remote_file_exists?(file["remote_file_url"])

          file_tmp = URI.open(file["remote_file_url"])

          Decidim.traceability.perform_action!("create", Attachment, @user) do
            attachment = Attachment.new(
              title: file["title"],
              description: file["description"],
              content_type: file_tmp.content_type,
              attached_to: @imported_process,
              weight: file["weight"],
              file: file_tmp, # Define attached_to before this
              file_size: file_tmp.size
            )
            attachment.create_attachment_collection(file["attachment_collection"])
            attachment.save!
            attachment
          end
        end

        attachments["attachment_collections"].map do |collection|
          Decidim.traceability.perform_action!("create", AttachmentCollection, @user) do
            create_attachment_collection(collection)
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

      def remote_file_exists?(url)
        return if url.nil?

        accepted = ["image", "application/pdf"]
        url = URI.parse(url)
        http_connection = Net::HTTP.new(url.host, url.port)
        http_connection.use_ssl = true if url.scheme == "https"
        http_connection.start do |http|
          return http.head(url.request_uri)["Content-Type"].start_with?(*accepted)
        end
      rescue StandardError
        nil
      end
    end
  end
end

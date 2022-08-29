# frozen_string_literal: true

module Decidim
  module Assemblies
    # A factory class to ensure we always create Assemblies the same way since it involves some logic.
    class AssemblyImporter < Decidim::Importers::Importer
      def initialize(organization, user)
        @organization = organization
        @user = user
      end

      # Public: Creates a new Assembly.
      #
      # attributes  - The Hash of attributes to create the Assembly with.
      # user        - The user that performs the action.
      # opts        - The options MUST contain:
      #   - title: The +title+ for the new Assembly
      #   - slug: The +slug+ for the new Assembly
      #
      # Returns a Assembly.
      def import(attributes, _user, opts)
        title = opts[:title]
        slug = opts[:slug]
        Decidim.traceability.perform_action!(:create, Assembly, @user, visibility: "all") do
          @imported_assembly = Assembly.new(
            organization: @organization,
            title:,
            slug:,
            hashtag: attributes["hashtag"],
            subtitle: attributes["subtitle"],
            short_description: attributes["short_description"],
            description: attributes["description"],
            promoted: attributes["promoted"],
            developer_group: attributes["developer_group"],
            local_area: attributes["local_area"],
            target: attributes["target"],
            participatory_scope: attributes["participatory_scope"],
            participatory_structure: attributes["participatory_structure"],
            show_statistics: attributes["show_statistics"],
            scopes_enabled: attributes["scopes_enabled"],
            private_space: attributes["private_space"],
            reference: attributes["reference"],
            purpose_of_action: attributes["purpose_of_action"],
            composition: attributes["composition"],
            duration: attributes["duration"],
            creation_date: attributes["creation_date"],
            decidim_scope_id: attributes["decidim_scope_id"],
            closing_date_reason: attributes["closing_date_reason"],
            included_at: attributes["included_at"],
            closing_date: attributes["closing_date"],
            created_by_other: attributes["created_by_other"],
            internal_organisation: attributes["internal_organisation"],
            is_transparent: attributes["is_transparent"],
            special_features: attributes["special_features"],
            twitter_handler: attributes["twitter_handler"],
            instagram_handler: attributes["instagram_handler"],
            facebook_handler: attributes["facebook_handler"],
            youtube_handler: attributes["youtube_handler"],
            github_handler: attributes["github_handler"],
            created_by: attributes["created_by"],
            meta_scope: attributes["meta_scope"],
            announcement: attributes["announcement"]
          )
          @imported_assembly.remote_hero_image_url = attributes["remote_hero_image_url"] if remote_file_exists?(attributes["remote_hero_image_url"])
          @imported_assembly.remote_banner_image_url = attributes["remote_banner_image_url"] if remote_file_exists?(attributes["remote_banner_image_url"])
          @imported_assembly.save!
          @imported_assembly
        end
      end

      def import_assemblies_type(type_id)
        return if Decidim::AssembliesType.find_by(id: type_id).nil?

        @imported_assembly.decidim_assemblies_type_id = type_id
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
            participatory_space: @imported_assembly
          )
          next if category_attributes["subcategories"].nil?

          category_attributes["subcategories"].map do |subcategory_attributes|
            Decidim.traceability.create!(
              Category,
              @user,
              name: subcategory_attributes["name"],
              description: subcategory_attributes["description"],
              parent_id: category.id,
              participatory_space: @imported_assembly
            )
          end
        end
      end

      def import_folders_and_attachments(attachments)
        return if attachments["files"].nil?

        attachments["files"].map do |file|
          next unless remote_file_exists?(file["remote_file_url"])

          file_tmp = URI.parse(file["remote_file_url"]).open

          Decidim.traceability.perform_action!("create", Attachment, @user) do
            attachment = Attachment.new(
              title: file["title"],
              description: file["description"],
              content_type: file_tmp.content_type,
              attached_to: @imported_assembly,
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

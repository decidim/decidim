# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A factory class to ensure we always create ParticipatoryProcesses the same way since it involves some logic.
    module ParticipatoryProcessBuilder
      # Public: Creates a new ParticipatoryProcess.
      #
      # attributes        - The Hash of attributes to create the ParticipatoryProcess with.
      # form              - 
      #
      # Returns a ParticipatoryProcess.
      def import(attributes, form)
        Decidim.traceability.perform_action!(:create, ParticipatoryProcess, form.current_user, visibility: "all") do
          @imported_process = ParticipatoryProcess.new(
            organization: form.current_organization,
            title: form.title,
            slug: form.slug,
            subtitle: attributes["subtitle"],
            hashtag: attributes["hashtag"],
            description: attributes["description"],
            short_description: attributes["short_description"],
            # PENDING HOw to solve images if not exists.
            remote_hero_image_url: attributes["remote_hero_image_url"],
            remote_banner_image_url: attributes["remote_banner_image_url"],
            promoted: attributes["promoted"],
            # scope: @participatory_process.scope,
            developer_group: attributes["developer_group"],
            local_area: attributes["local_area"],
            # area: @participatory_process.area,
            target: attributes["target"],
            participatory_scope: attributes["participatory_scope"],
            participatory_structure: attributes["participatory_structure"],
            meta_scope: attributes["meta_scope"],
            start_date: attributes["start_date"],
            end_date: attributes["end_date"],
            private_space: attributes["private_space"],
            participatory_process_group: import_process_group(attributes["participatory_process_group"], form)
          )
          
          #proposal.add_coauthor(author, user_group: user_group_author)
          @imported_process.save!
          @imported_process
        end
      end

      module_function :import

      def import_process_group(attributes, form)
        Decidim.traceability.perform_action!("create", ParticipatoryProcessGroup, form.current_user ) do
          group = ParticipatoryProcessGroup.find_or_initialize_by(
            name: attributes["name"],
            description: attributes["description"],
            organization: form.current_organization
          )

          # PENDING HOw to solve images if not exists.
          # group.remote_hero_image_url= attributes["remote_hero_image_url"] 
          group.save!
          group
        end
      end

      module_function :import_process_group

      def import_participatory_process_steps(steps, form)
        steps.map do |step_attributes|
          Decidim.traceability.create!(
            ParticipatoryProcessStep,
            form.current_user,
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

      module_function :import_participatory_process_steps

      def import_categories(categories, form)
        categories.map do |category_attributes|
          category = Decidim.traceability.create!(
            Category,
            form.current_user,
            name: category_attributes["name"],
            description: category_attributes["description"],
            parent_id: category_attributes["parent_id"],
            participatory_space: @imported_process
          )
          category_attributes["subcategories"].map do |subcategory_attributes|
            Decidim.traceability.create!(
              Category,
              form.current_user,
              name: subcategory_attributes["name"],
              description: subcategory_attributes["description"],
              parent_id: category.id,
              participatory_space: @imported_process
            ) 
          end
        end
      end

      module_function :import_categories

      def import_folders_and_attachments(attachments, form)
        
        raise
      end

      module_function :import_folders_and_attachments
    end
  end
end

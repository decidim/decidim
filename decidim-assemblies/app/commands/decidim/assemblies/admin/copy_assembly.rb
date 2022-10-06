# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when copying a new participatory
      # assembly in the system.
      class CopyAssembly < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # assembly - An assembly we want to duplicate
        def initialize(form, assembly, user)
          @form = form
          @assembly = assembly
          @user = user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          Decidim.traceability.perform_action!("duplicate", @assembly, @user) do
            Assembly.transaction do
              copy_assembly
              copy_assembly_attachments
              copy_assembly_categories if @form.copy_categories?
              copy_assembly_components if @form.copy_components?
            end
          end

          broadcast(:ok, @copied_assembly)
        end

        private

        attr_reader :form

        def copy_assembly
          @copied_assembly = Assembly.create!(
            organization: @assembly.organization,
            title: form.title,
            subtitle: @assembly.subtitle,
            slug: form.slug,
            hashtag: @assembly.hashtag,
            description: @assembly.description,
            short_description: @assembly.short_description,
            promoted: @assembly.promoted,
            scope: @assembly.scope,
            parent: @assembly.parent,
            developer_group: @assembly.developer_group,
            local_area: @assembly.local_area,
            area: @assembly.area,
            target: @assembly.target,
            participatory_scope: @assembly.participatory_scope,
            participatory_structure: @assembly.participatory_structure,
            meta_scope: @assembly.meta_scope,
            announcement: @assembly.announcement
          )
        end

        def copy_assembly_attachments
          [:hero_image, :banner_image].each do |attribute|
            next unless @assembly.attached_uploader(attribute).attached?

            @copied_assembly.send(attribute).attach(@assembly.send(attribute).blob)
          end
        end

        def copy_assembly_categories
          @assembly.categories.each do |category|
            Category.create!(
              name: category.name,
              description: category.description,
              parent_id: category.parent_id,
              participatory_space: @copied_assembly
            )
          end
        end

        def copy_assembly_components
          @assembly.components.each do |component|
            new_component = Component.create!(
              manifest_name: component.manifest_name,
              name: component.name,
              participatory_space: @copied_assembly,
              settings: component.settings,
              step_settings: component.step_settings,
              weight: component.weight
            )
            component.manifest.run_hooks(:copy, new_component:, old_component: component)
          end
        end
      end
    end
  end
end

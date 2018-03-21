# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when copying a new participatory
      # assembly in the system.
      class CopyAssembly < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # assembly - An assembly we want to duplicate
        def initialize(form, assembly)
          @form = form
          @assembly = assembly
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          Assembly.transaction do
            copy_assembly
            copy_assembly_categories if @form.copy_categories?
            copy_assembly_components if @form.copy_components?
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
            hero_image: @assembly.hero_image,
            banner_image: @assembly.banner_image,
            promoted: @assembly.promoted,
            scope: @assembly.scope,
            developer_group: @assembly.developer_group,
            local_area: @assembly.local_area,
            target: @assembly.target,
            participatory_scope: @assembly.participatory_scope,
            participatory_structure: @assembly.participatory_structure,
            meta_scope: @assembly.meta_scope
          )
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
              step_settings: component.step_settings
            )
            component.manifest.run_hooks(:copy, new_component: new_component, old_component: component)
          end
        end
      end
    end
  end
end

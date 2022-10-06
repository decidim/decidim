# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when copying a new participatory
      # process in the system.
      class CopyParticipatoryProcess < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # participatory_process - A participatory_process we want to duplicate
        def initialize(form, participatory_process, current_user)
          @form = form
          @participatory_process = participatory_process
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          Decidim.traceability.perform_action!("duplicate", @participatory_process, @current_user) do
            ParticipatoryProcess.transaction do
              copy_participatory_process
              copy_participatory_process_attachments
              copy_participatory_process_steps if @form.copy_steps?
              copy_participatory_process_categories if @form.copy_categories?
              copy_participatory_process_components if @form.copy_components?
            end
          end

          broadcast(:ok, @copied_process)
        end

        private

        attr_reader :form

        def copy_participatory_process
          @copied_process = ParticipatoryProcess.create!(
            organization: @participatory_process.organization,
            title: form.title,
            subtitle: @participatory_process.subtitle,
            slug: form.slug,
            hashtag: @participatory_process.hashtag,
            description: @participatory_process.description,
            short_description: @participatory_process.short_description,
            promoted: @participatory_process.promoted,
            scope: @participatory_process.scope,
            developer_group: @participatory_process.developer_group,
            local_area: @participatory_process.local_area,
            area: @participatory_process.area,
            target: @participatory_process.target,
            participatory_scope: @participatory_process.participatory_scope,
            participatory_structure: @participatory_process.participatory_structure,
            meta_scope: @participatory_process.meta_scope,
            start_date: @participatory_process.start_date,
            end_date: @participatory_process.end_date,
            participatory_process_group: @participatory_process.participatory_process_group,
            private_space: @participatory_process.private_space
          )
        end

        def copy_participatory_process_attachments
          [:hero_image, :banner_image].each do |attribute|
            next unless @participatory_process.attached_uploader(attribute).attached?

            @copied_process.send(attribute).attach(@participatory_process.send(attribute).blob)
          end
        end

        def copy_participatory_process_steps
          @steps_relationship = {}

          @participatory_process.steps.each do |step|
            new_step = ParticipatoryProcessStep.create!(
              title: step.title,
              description: step.description,
              start_date: step.start_date,
              end_date: step.end_date,
              participatory_process: @copied_process,
              position: step.position,
              active: step.active
            )
            @steps_relationship[step.id.to_s] = new_step.id.to_s
          end
        end

        def copy_participatory_process_categories
          @participatory_process.categories.first_class.each do |category|
            new_category = Category.create!(
              name: category.name,
              description: category.description,
              participatory_space: @copied_process
            )

            category.descendants.each do |child|
              Category.create!(
                name: child.name,
                description: child.description,
                participatory_space: @copied_process,
                parent: new_category
              )
            end
          end
        end

        def copy_participatory_process_components
          @participatory_process.components.each do |component|
            copied_step_settings = @form.copy_steps? ? map_step_settings(component.step_settings) : {}
            new_component = Component.create!(
              manifest_name: component.manifest_name,
              name: component.name,
              participatory_space: @copied_process,
              settings: component.settings,
              step_settings: copied_step_settings,
              weight: component.weight
            )
            component.manifest.run_hooks(:copy, new_component:, old_component: component)
          end
        end

        def map_step_settings(step_settings)
          step_settings.each_with_object({}) do |(step_id, settings), acc|
            acc.update(@steps_relationship[step_id.to_s] => settings)
          end
        end
      end
    end
  end
end

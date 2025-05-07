# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when copying a new participatory
      # process in the system.
      class CopyParticipatoryProcess < Decidim::Command
        delegate :current_user, to: :form
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # participatory_process - A participatory_process we want to duplicate
        def initialize(form, participatory_process)
          @form = form
          @participatory_process = participatory_process
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          Decidim.traceability.perform_action!("duplicate", @participatory_process, current_user) do
            ParticipatoryProcess.transaction do
              copy_participatory_process
              copy_participatory_process_attachments
              copy_participatory_process_steps if @form.copy_steps?
              copy_participatory_process_components if @form.copy_components?
              copy_landing_page_blocks if @form.copy_landing_page_blocks?
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
            developer_group: @participatory_process.developer_group,
            local_area: @participatory_process.local_area,
            target: @participatory_process.target,
            participatory_scope: @participatory_process.participatory_scope,
            participatory_structure: @participatory_process.participatory_structure,
            meta_scope: @participatory_process.meta_scope,
            start_date: @participatory_process.start_date,
            end_date: @participatory_process.end_date,
            participatory_process_group: @participatory_process.participatory_process_group,
            private_space: @participatory_process.private_space,
            taxonomies: @participatory_process.taxonomies
          )
        end

        def copy_participatory_process_attachments
          return unless @participatory_process.attached_uploader(:hero_image).attached?

          @copied_process.send(:hero_image).attach(@participatory_process.send(:hero_image).blob)
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

        def copy_landing_page_blocks
          blocks = Decidim::ContentBlock.where(scoped_resource_id: @participatory_process.id, scope_name: "participatory_process_homepage",
                                               organization: @participatory_process.organization)
          return if blocks.blank?

          blocks.each do |block|
            new_block = Decidim::ContentBlock.create!(
              organization: @copied_process.organization,
              scope_name: "participatory_process_homepage",
              scoped_resource_id: @copied_process.id,
              manifest_name: block.manifest_name,
              settings: block.settings,
              weight: block.weight,
              published_at: block.published_at.present? ? @copied_process.created_at : nil # determine if block is active/inactive
            )
            copy_block_attachments(block, new_block) if block.attachments.present?
          end
        end

        def copy_block_attachments(block, new_block)
          block.attachments.map(&:name).each do |name|
            original_image = block.images_container.send(name).blob
            next if original_image.blank?

            new_block.images_container.send("#{name}=", ActiveStorage::Blob.create_and_upload!(
                                                          io: StringIO.new(original_image.download),
                                                          filename: "image.png",
                                                          content_type: block.images_container.background_image.blob.content_type
                                                        ))
            new_block.save!
          end
        end
      end
    end
  end
end

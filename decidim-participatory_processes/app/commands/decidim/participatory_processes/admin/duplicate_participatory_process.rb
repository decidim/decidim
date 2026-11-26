# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when duplicating a new participatory
      # process in the system.
      class DuplicateParticipatoryProcess < Decidim::Command
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
              duplicate_participatory_process
              duplicate_participatory_process_attachments
              duplicate_landing_page_blocks
              duplicate_participatory_process_phases if @form.duplicate_phases?
              duplicate_participatory_process_components if @form.duplicate_components?
            end
          end

          broadcast(:ok, @duplicated_process)
        end

        private

        attr_reader :form

        def duplicate_participatory_process
          @duplicated_process = ParticipatoryProcess.create!(
            organization: @participatory_process.organization,
            title: form.title,
            subtitle: @participatory_process.subtitle,
            slug: form.slug,
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
            access_mode: @participatory_process.access_mode,
            taxonomies: @participatory_process.taxonomies
          )
        end

        def duplicate_participatory_process_attachments
          return unless @participatory_process.attached_uploader(:hero_image).attached?

          @duplicated_process.send(:hero_image).attach(@participatory_process.send(:hero_image).blob)
        end

        def duplicate_participatory_process_phases
          @phases_relationship = {}

          @participatory_process.phases.each do |phase|
            new_phase = ParticipatoryProcessPhase.create!(
              title: phase.title,
              description: phase.description,
              start_date: phase.start_date,
              end_date: phase.end_date,
              participatory_process: @duplicated_process,
              position: phase.position,
              active: phase.active
            )
            @phases_relationship[phase.id.to_s] = new_phase.id.to_s
          end
        end

        def duplicate_participatory_process_components
          @participatory_process.components.each do |component|
            duplicated_phase_settings = @form.duplicate_phases? ? map_phase_settings(component.phase_settings) : {}
            new_component = Component.create!(
              manifest_name: component.manifest_name,
              name: component.name,
              participatory_space: @duplicated_process,
              settings: component.settings,
              phase_settings: duplicated_phase_settings,
              weight: component.weight
            )
            component.manifest.run_hooks(:duplicate, new_component:, old_component: component)
          end
        end

        def map_phase_settings(phase_settings)
          phase_settings.each_with_object({}) do |(phase_id, settings), acc|
            acc.update(@phases_relationship[phase_id.to_s] => settings)
          end
        end

        def duplicate_landing_page_blocks
          blocks = Decidim::ContentBlock.where(scoped_resource_id: @participatory_process.id, scope_name: "participatory_process_homepage",
                                               organization: @participatory_process.organization)
          return if blocks.blank?

          blocks.each do |block|
            new_block = Decidim::ContentBlock.create!(
              organization: @duplicated_process.organization,
              scope_name: "participatory_process_homepage",
              scoped_resource_id: @duplicated_process.id,
              manifest_name: block.manifest_name,
              settings: block.settings,
              weight: block.weight,
              published_at: block.published_at.present? ? @duplicated_process.created_at : nil # determine if block is active/inactive
            )
            duplicate_block_attachments(block, new_block) if block.attachments.present?
          end
        end

        def duplicate_block_attachments(block, new_block)
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

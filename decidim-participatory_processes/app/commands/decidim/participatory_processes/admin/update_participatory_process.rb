# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when creating a new participatory
      # process in the system.
      class UpdateParticipatoryProcess < Rectify::Command
        # Public: Initializes the command.
        #
        # participatory_process - the ParticipatoryProcess to update
        # form - A form object with the params.
        def initialize(participatory_process, form)
          @participatory_process = participatory_process
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_participatory_process

          if @participatory_process.valid?
            broadcast(:ok, @participatory_process)
          else
            form.errors.add(:hero_image, @participatory_process.errors[:hero_image]) if @participatory_process.errors.include? :hero_image
            form.errors.add(:banner_image, @participatory_process.errors[:banner_image]) if @participatory_process.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :participatory_process

        def update_participatory_process
          @participatory_process.assign_attributes(attributes)
          return unless @participatory_process.valid?

          @participatory_process.save!

          Decidim.traceability.perform_action!(:update, @participatory_process, form.current_user) do
            @participatory_process
          end
          link_related_processes
        end

        def attributes
          {
            title: form.title,
            subtitle: form.subtitle,
            weight: form.weight,
            slug: form.slug,
            hashtag: form.hashtag,
            promoted: form.promoted,
            description: form.description,
            short_description: form.short_description,
            scopes_enabled: form.scopes_enabled,
            scope: form.scope,
            scope_type_max_depth: form.scope_type_max_depth,
            private_space: form.private_space,
            developer_group: form.developer_group,
            local_area: form.local_area,
            area: form.area,
            target: form.target,
            participatory_scope: form.participatory_scope,
            participatory_structure: form.participatory_structure,
            meta_scope: form.meta_scope,
            start_date: form.start_date,
            end_date: form.end_date,
            participatory_process_group: form.participatory_process_group,
            show_metrics: form.show_metrics,
            show_statistics: form.show_statistics,
            announcement: form.announcement
          }.merge(uploader_attributes)
        end

        def uploader_attributes
          {
            hero_image: form.hero_image,
            remove_hero_image: form.remove_hero_image,
            banner_image: form.banner_image,
            remove_banner_image: form.remove_banner_image
          }.delete_if { |_k, val| val.is_a?(Decidim::ApplicationUploader) }
        end

        def related_processes
          @related_processes ||= Decidim::ParticipatoryProcess.where(id: form.related_process_ids)
        end

        def link_related_processes
          @participatory_process.link_participatory_space_resources(related_processes, "related_processes")
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when updating a participatory
      # process in the system.
      class UpdateParticipatoryProcess < Decidim::Commands::UpdateResource
        include ::Decidim::AttachmentAttributesMethods

        fetch_form_attributes :title, :subtitle, :weight, :slug, :hashtag, :promoted, :description,
                              :short_description, :scopes_enabled, :scope, :scope_type_max_depth,
                              :private_space, :developer_group, :local_area, :area, :target, :participatory_scope,
                              :participatory_structure, :meta_scope, :start_date, :end_date, :participatory_process_group,
                              :participatory_process_type, :show_metrics, :show_statistics, :announcement

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if invalid?

          transaction do
            update_resource
            run_after_hooks
          end

          broadcast(:ok, resource)
        rescue Decidim::Commands::HookError, ActiveRecord::RecordInvalid
          form.errors.add(:hero_image, resource.errors[:hero_image]) if resource.errors.include? :hero_image
          form.errors.add(:banner_image, resource.errors[:banner_image]) if resource.errors.include? :banner_image
          broadcast(:invalid)
        end

        private

        def attributes
          super.merge(attachment_attributes(:hero_image, :banner_image))
        end

        def related_processes
          @related_processes ||= Decidim::ParticipatoryProcess.where(id: form.related_process_ids)
        end

        def run_after_hooks
          resource.link_participatory_space_resources(related_processes, "related_processes")
        end
      end
    end
  end
end

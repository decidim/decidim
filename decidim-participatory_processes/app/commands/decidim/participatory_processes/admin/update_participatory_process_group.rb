# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when updating a participatory
      # process group in the system.
      class UpdateParticipatoryProcessGroup < Decidim::Commands::UpdateResource
        include ::Decidim::AttachmentAttributesMethods

        fetch_form_attributes :title, :description, :hashtag, :group_url, :developer_group, :local_area,
                              :meta_scope, :participatory_scope, :participatory_structure, :target, :promoted

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if invalid?

          transaction do
            run_before_hooks
            update_resource
            run_after_hooks
          end
          broadcast(:ok, resource)
        rescue Decidim::Commands::HookError, ActiveRecord::RecordInvalid
          form.errors.add(:hero_image, resource.errors[:hero_image]) if resource.errors.include? :hero_image

          broadcast(:invalid)
        end

        private

        attr_reader :form

        def attributes
          super
            .merge({ participatory_processes: })
            .merge(attachment_attributes(:hero_image))
        end

        def participatory_processes
          Decidim::ParticipatoryProcess.where(id: form.participatory_process_ids)
        end
      end
    end
  end
end

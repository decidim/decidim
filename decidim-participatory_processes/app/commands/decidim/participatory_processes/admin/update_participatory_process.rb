# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when updating a participatory
      # process in the system.
      class UpdateParticipatoryProcess < Decidim::Commands::UpdateResource
        fetch_file_attributes :hero_image

        fetch_form_attributes :title, :subtitle, :weight, :slug, :hashtag, :promoted, :description,
                              :short_description, :taxonomizations,
                              :private_space, :developer_group, :local_area, :target, :participatory_scope,
                              :participatory_structure, :meta_scope, :start_date, :end_date, :participatory_process_group,
                              :announcement

        private

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

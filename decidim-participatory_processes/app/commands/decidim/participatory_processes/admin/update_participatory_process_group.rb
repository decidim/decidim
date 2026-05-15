# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when updating a participatory
      # process group in the system.
      class UpdateParticipatoryProcessGroup < Decidim::Commands::UpdateResource
        fetch_file_attributes :hero_image

        fetch_form_attributes :title, :description, :group_url, :developer_group, :local_area,
                              :meta_scope, :participatory_scope, :participatory_structure, :target, :promoted

        private

        attr_reader :form

        def attributes
          super.merge({ participatory_processes: })
        end

        def participatory_processes
          Decidim::ParticipatoryProcess.where(id: form.participatory_process_ids)
        end
      end
    end
  end
end

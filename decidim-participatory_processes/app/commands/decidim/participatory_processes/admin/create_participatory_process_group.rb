# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when creating a new participatory
      # process group in the system.
      class CreateParticipatoryProcessGroup < Decidim::Commands::CreateResource
        fetch_file_attributes :hero_image

        fetch_form_attributes :organization, :title, :description, :group_url, :target, :promoted,
                              :developer_group, :local_area, :meta_scope, :participatory_scope, :participatory_structure

        protected

        def run_after_hooks
          Decidim::ContentBlocksCreator.new(resource).create_default!
        end

        def resource_class = Decidim::ParticipatoryProcessGroup

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

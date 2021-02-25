# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessGroups
    class ContentBlockCell < Decidim::Admin::ContentBlockCell
      delegate :scoped_resource, to: :controller

      def edit_content_block_path
        decidim_participatory_processes.edit_participatory_process_group_landing_page_content_block_path(scoped_resource, manifest_name)
      end

      def decidim_participatory_processes
        Decidim::ParticipatoryProcesses::AdminEngine.routes.url_helpers
      end
    end
  end
end

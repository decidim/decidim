# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows to manage the content from the participatory process landing page content blocks
      class ParticipatoryProcessLandingPageContentBlocksController < Decidim::ParticipatoryProcesses::Admin::ApplicationController
        include Decidim::Admin::ContentBlocks::LandingPageContentBlocks
        include Concerns::ParticipatoryProcessAdmin

        layout "decidim/admin/participatory_process"

        private

        def content_block_scope
          :participatory_process_homepage
        end

        alias scoped_resource current_participatory_space

        def enforce_permission_to_update_resource
          enforce_permission_to :update, :process, process: scoped_resource
        end

        def edit_resource_landing_page_path
          edit_participatory_process_landing_page_path(scoped_resource)
        end

        def resource_landing_page_content_block_path
          participatory_process_landing_page_content_block_path(scoped_resource, params[:id])
        end

        def submit_button_text
          t("participatory_process_group_landing_page_content_blocks.edit.update", scope: "decidim.admin")
        end

        def content_block_create_success_text
          t("participatory_process_group_landing_page_content_blocks.create.success", scope: "decidim.admin")
        end

        def content_block_create_error_text
          t("participatory_process_group_landing_page_content_blocks.create.error", scope: "decidim.admin")
        end

        def content_block_destroy_success_text
          t("participatory_process_group_landing_page_content_blocks.destroy.success", scope: "decidim.admin")
        end

        def content_block_destroy_error_text
          t("participatory_process_group_landing_page_content_blocks.destroy.error", scope: "decidim.admin")
        end
      end
    end
  end
end

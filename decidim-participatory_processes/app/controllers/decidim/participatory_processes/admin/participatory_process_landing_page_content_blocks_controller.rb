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

        def content_block_destroy_error_text = t("destroy.error", scope: i18n_scope)
      end
    end
  end
end

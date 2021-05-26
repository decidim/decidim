# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows to manage the content from the participatory process landing page content blocks
      class ParticipatoryProcessGroupLandingPageContentBlocksController < Decidim::ParticipatoryProcesses::Admin::ApplicationController
        include Decidim::Admin::LandingPageContentBlocks

        layout "decidim/admin/participatory_process_group"

        helper_method :participatory_process_group

        private

        def content_block_scope
          :participatory_process_group_homepage
        end

        def scoped_resource
          @scoped_resource ||= collection.find(params[:participatory_process_group_id])
        end

        def enforce_permission_to_update_resource
          enforce_permission_to :update, :process_group, process_group: scoped_resource
        end

        def edit_resource_landing_page_path
          edit_participatory_process_group_landing_page_path(scoped_resource)
        end

        def resource_landing_page_content_block_path
          participatory_process_group_landing_page_content_block_path(scoped_resource, params[:id])
        end

        def submit_button_text
          t("participatory_process_group_landing_page_content_blocks.edit.update", scope: "decidim.admin")
        end

        alias participatory_process_group scoped_resource

        def collection
          @collection ||= OrganizationParticipatoryProcessGroups.new(current_user.organization).query
        end
      end
    end
  end
end

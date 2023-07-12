# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing the participatory process group landing
      # page
      class ParticipatoryProcessGroupLandingPageController < Decidim::ParticipatoryProcesses::Admin::ApplicationController
        include Decidim::Admin::ContentBlocks::LandingPage

        layout "decidim/admin/participatory_process_group"

        helper_method :participatory_process_group

        def content_block_scope
          :participatory_process_group_homepage
        end

        def scoped_resource
          @scoped_resource ||= collection.find(params[:participatory_process_group_id])
        end

        def enforce_permission_to_update_resource
          enforce_permission_to :update, :process_group, process_group: scoped_resource
        end

        def resource_sort_url
          participatory_process_group_landing_page_path(scoped_resource)
        end

        def resource_create_url(manifest_name)
          participatory_process_group_landing_page_content_blocks_path(participatory_process_group_id: params[:participatory_process_group_id],
                                                                       manifest_name:)
        end

        def content_blocks_title
          t("participatory_process_group_landing_page.edit.title", scope: "decidim.admin")
        end

        def add_content_block_text
          t("participatory_process_group_landing_page.edit.add", scope: "decidim.admin")
        end

        def content_block_destroy_confirmation_text
          t("participatory_process_group_landing_page.edit.destroy_confirmation", scope: "decidim.admin")
        end

        def active_content_blocks_title
          t("participatory_process_group_landing_page.edit.active_content_blocks", scope: "decidim.admin")
        end

        def inactive_content_blocks_title
          t("participatory_process_group_landing_page.edit.inactive_content_blocks", scope: "decidim.admin")
        end

        def resource_content_block_cell
          "decidim/participatory_process_groups/content_block"
        end

        alias participatory_process_group scoped_resource

        private

        def collection
          @collection ||= OrganizationParticipatoryProcessGroups.new(current_user.organization).query
        end
      end
    end
  end
end

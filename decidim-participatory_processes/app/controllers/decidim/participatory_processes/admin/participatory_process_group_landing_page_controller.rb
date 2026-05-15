# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing the participatory process group landing
      # page
      class ParticipatoryProcessGroupLandingPageController < Decidim::ParticipatoryProcesses::Admin::ApplicationController
        include Decidim::Admin::ContentBlocks::LandingPage
        include Decidim::TranslatableAttributes

        before_action :set_context_breadcrumb
        add_breadcrumb_item_from_menu :admin_participatory_process_group_menu

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

        def resource_content_block_cell
          "decidim/participatory_process_groups/content_block"
        end

        alias participatory_process_group scoped_resource

        def content_blocks_title
          t("decidim.admin.menu.participatory_process_groups_submenu.landing_page")
        end

        private

        def collection
          @collection ||= OrganizationParticipatoryProcessGroups.new(current_user.organization).query
        end

        def set_context_breadcrumb
          @context_breadcrumb_items ||= [
            {
              label: I18n.t("menu.participatory_process_groups", scope: "decidim.admin"),
              url: decidim_admin_participatory_processes.participatory_process_groups_path,
              active: false
            },
            {
              label: translated_attribute(scoped_resource.title),
              url: edit_participatory_process_group_path(scoped_resource),
              active: false,
              resource: scoped_resource
            }
          ]
        end
      end
    end
  end
end

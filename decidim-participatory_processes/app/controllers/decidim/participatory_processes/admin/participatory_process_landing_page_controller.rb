# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing the participatory process landing page
      class ParticipatoryProcessLandingPageController < Decidim::ParticipatoryProcesses::Admin::ApplicationController
        include Decidim::Admin::ContentBlocks::LandingPage
        include Concerns::ParticipatoryProcessAdmin

        layout "decidim/admin/participatory_process"

        def content_block_scope
          current_participatory_space_manifest.content_blocks_scope_name
        end

        alias scoped_resource current_participatory_space

        def enforce_permission_to_update_resource
          enforce_permission_to :update, :process, process: scoped_resource
        end

        def resource_sort_url
          participatory_process_landing_page_path(scoped_resource)
        end

        def resource_create_url(manifest_name)
          participatory_process_landing_page_content_blocks_path(slug: params[:slug], manifest_name:)
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
          "decidim/participatory_processes/content_block"
        end
      end
    end
  end
end

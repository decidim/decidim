# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows to manage the content from the assembly landing page content blocks
      class AssemblyLandingPageContentBlocksController < Decidim::Assemblies::Admin::ApplicationController
        include Decidim::Admin::ContentBlocks::LandingPageContentBlocks
        include Concerns::AssemblyAdmin

        layout "decidim/admin/assemblies"

        private

        def content_block_scope
          current_participatory_space_manifest.content_blocks_scope_name
        end

        alias scoped_resource current_participatory_space

        def enforce_permission_to_update_resource
          enforce_permission_to :update, :assembly, assembly: scoped_resource
        end

        def edit_resource_landing_page_path
          edit_assembly_landing_page_path(scoped_resource)
        end

        def resource_landing_page_content_block_path
          assembly_landing_page_content_block_path(scoped_resource, params[:id])
        end

        def submit_button_text
          t("organization_homepage.content_blocks.edit.update", scope: "decidim.admin")
        end

        def content_block_create_success_text
          t("organization_homepage.content_blocks.create.success", scope: "decidim.admin")
        end

        def content_block_create_error_text
          t("organization_homepage.content_blocks.create.error", scope: "decidim.admin")
        end

        def content_block_destroy_success_text
          t("organization_homepage.content_blocks.destroy.success", scope: "decidim.admin")
        end

        def content_block_destroy_error_text
          t("organization_homepage.content_blocks.destroy.error", scope: "decidim.admin")
        end
      end
    end
  end
end

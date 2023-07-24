# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing the assembly landing page
      class AssemblyLandingPageController < Decidim::Assemblies::Admin::ApplicationController
        include Decidim::Admin::ContentBlocks::LandingPage
        include Concerns::AssemblyAdmin

        layout "decidim/admin/assembly"

        def content_block_scope
          current_participatory_space_manifest.content_blocks_scope_name
        end

        alias scoped_resource current_participatory_space

        def enforce_permission_to_update_resource
          enforce_permission_to :update, :assembly, assembly: scoped_resource
        end

        def resource_sort_url
          assembly_landing_page_path(scoped_resource)
        end

        def resource_create_url(manifest_name)
          assembly_landing_page_content_blocks_path(slug: params[:slug], manifest_name:)
        end

        def content_blocks_title
          t("organization_homepage.edit.title", scope: "decidim.admin")
        end

        def add_content_block_text
          t("organization_homepage.edit.add", scope: "decidim.admin")
        end

        def content_block_destroy_confirmation_text
          t("organization_homepage.edit.destroy_confirmation", scope: "decidim.admin")
        end

        def active_content_blocks_title
          t("organization_homepage.edit.active_content_blocks", scope: "decidim.admin")
        end

        def inactive_content_blocks_title
          t("organization_homepage.edit.inactive_content_blocks", scope: "decidim.admin")
        end

        def resource_content_block_cell
          "decidim/assemblies/content_block"
        end
      end
    end
  end
end

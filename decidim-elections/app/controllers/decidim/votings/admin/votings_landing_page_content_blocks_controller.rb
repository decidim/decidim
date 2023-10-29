# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # Controller that allows to edit the content of the landing page content blocks
      class VotingsLandingPageContentBlocksController < Decidim::Votings::Admin::ApplicationController
        include Decidim::Admin::ContentBlocks::LandingPageContentBlocks

        layout "decidim/admin/voting"

        helper_method :current_participatory_space

        private

        def content_block_scope
          :voting_landing_page
        end

        def scoped_resource
          @scoped_resource ||= Voting.find_by(slug: params[:voting_slug], organization: current_organization)
        end

        def enforce_permission_to_update_resource
          enforce_permission_to :manage_landing_page, :voting, voting: current_participatory_space
        end

        def edit_resource_landing_page_path
          edit_voting_landing_page_path(scoped_resource)
        end

        def resource_landing_page_content_block_path
          voting_landing_page_content_block_path(scoped_resource, params[:id])
        end

        def i18n_scope = "decidim.votings.admin.landing_page.content_blocks"

        def submit_button_text = t("edit.update", scope: i18n_scope)

        def content_block_create_success_text = t("create.success", scope: i18n_scope)

        def content_block_create_error_text = t("create.error", scope: i18n_scope)

        def content_block_destroy_success_text = t("destroy.success", scope: i18n_scope)

        def content_block_destroy_error_text = t("destroy.error", scope: i18n_scope)

        alias current_participatory_space scoped_resource
      end
    end
  end
end

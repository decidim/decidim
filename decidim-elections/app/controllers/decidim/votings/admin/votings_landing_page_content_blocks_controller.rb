# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # Controller that allows to edit the content of the landing page content blocks
      class VotingsLandingPageContentBlocksController < Decidim::Votings::Admin::ApplicationController
        include Decidim::Admin::LandingPageContentBlocks

        layout "decidim/admin/voting"

        helper_method :current_participatory_space

        private

        def content_block_scope
          :voting_landing_page
        end

        def scoped_resource
          @scoped_resource ||= Voting.find_by(slug: params[:voting_slug])
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

        def submit_button_text
          t("landing_page.content_blocks.edit.update", scope: "decidim.votings.admin")
        end

        alias current_participatory_space scoped_resource
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # Controller that allows to (de)activate the content blocks from a voting landing page
      class VotingsLandingPageController < Decidim::Votings::Admin::ApplicationController
        include Decidim::Admin::ContentBlocks::LandingPage

        layout "decidim/admin/voting"

        helper_method :current_participatory_space

        def content_block_scope
          :voting_landing_page
        end

        def scoped_resource
          @scoped_resource ||= Voting.find_by(slug: params[:voting_slug], organization: current_organization)
        end

        def enforce_permission_to_update_resource
          enforce_permission_to :manage_landing_page, :voting, voting: scoped_resource
        end

        def resource_sort_url
          voting_landing_page_path(scoped_resource)
        end

        def resource_create_url(manifest_name)
          voting_landing_page_content_blocks_path(participatory_process_group_id: params[:participatory_process_group_id],
                                                  manifest_name:)
        end

        def resource_content_block_cell
          "decidim/votings/content_block"
        end

        alias current_participatory_space scoped_resource
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # Controller that allows managing the participatory process group landing
      # page
      class VotingsLandingPageController < Decidim::Votings::Admin::ApplicationController
        helper_method :active_blocks, :inactive_blocks, :current_participatory_space

        def edit
          enforce_permission_to :update, :voting, voting: current_participatory_space
          render layout: "decidim/admin/voting"
        end

        def update
          enforce_permission_to :update, :voting, voting: current_participatory_space
          Decidim::Admin::ReorderContentBlocks.call(current_organization, :voting_landing_page, params[:manifests], current_participatory_space.id) do
            on(:ok) do
              head :ok
            end
            on(:invalid) do
              head :bad_request
            end
          end
        end

        def current_participatory_space
          @current_participatory_space ||= collection.find_by(id: params[:voting_id]) || collection.find_by(slug: params[:voting_slug])
        end

        private

        def collection
          @collection ||= OrganizationVotings.new(current_user.organization).query
        end

        def content_blocks
          @content_blocks ||= Decidim::ContentBlock.for_scope(
            :voting_landing_page,
            organization: current_organization
          ).where(scoped_resource_id: current_participatory_space.id)
        end

        def active_blocks
          @active_blocks ||= content_blocks.published
        end

        def inactive_blocks
          @inactive_blocks ||= content_blocks.unpublished + unused_manifests
        end

        def used_manifests
          @used_manifests ||= content_blocks.map(&:manifest_name)
        end

        def unused_manifests
          @unused_manifests ||= Decidim.content_blocks.for(:voting_landing_page).reject do |manifest|
            used_manifests.include?(manifest.name.to_s)
          end
        end
      end
    end
  end
end

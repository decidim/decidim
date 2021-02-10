# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # Controller that allows managing the participatory process landing page content blocks
      class VotingsLandingPageContentBlocksController < Decidim::Votings::Admin::ApplicationController
        layout "decidim/admin/voting"

        helper_method :content_block, :current_participatory_space

        def edit
          enforce_permission_to :read, :voting, voting: current_participatory_space
          @form = form(Decidim::Admin::ContentBlockForm).from_model(content_block)
        end

        def update
          enforce_permission_to :read, :voting, voting: current_participatory_space
          @form = form(Decidim::Admin::ContentBlockForm).from_params(params)

          Decidim::Admin::UpdateContentBlock.call(@form, content_block, :voting_landing_page) do
            on(:ok) do
              redirect_to edit_voting_landing_page_path(current_participatory_space)
            end
            on(:invalid) do
              render :edit
            end
          end
        end

        private

        def current_participatory_space
          @current_participatory_space ||= collection.find_by(slug: params[:voting_slug])
        end

        def collection
          @collection ||= OrganizationVotings.new(current_user.organization).query
        end

        def content_block
          @content_block ||= content_blocks.find_by(manifest_name: params[:id]) || content_block_from_manifest
        end

        def content_block_manifest
          @content_block_manifest = unused_content_block_manifests.find { |manifest| manifest.name.to_s == params[:id] }
        end

        def content_blocks
          @content_blocks ||= Decidim::ContentBlock.for_scope(
            :voting_landing_page,
            organization: current_organization
          ).where(scoped_resource_id: current_participatory_space.id)
        end

        def used_content_block_manifests
          @used_content_block_manifests ||= content_blocks.map(&:manifest_name)
        end

        def unused_content_block_manifests
          @unused_content_block_manifests ||= Decidim.content_blocks.for(:voting_landing_page).reject do |manifest|
            used_content_block_manifests.include?(manifest.name.to_s)
          end
        end

        def content_block_from_manifest
          Decidim::ContentBlock.create!(
            organization: current_organization,
            scope_name: :voting_landing_page,
            scoped_resource_id: current_participatory_space.id,
            manifest_name: params[:id]
          )
        end
      end
    end
  end
end

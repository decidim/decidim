# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing the participatory process landing page content blocks
      class ParticipatoryProcessGroupLandingPageContentBlocksController < Decidim::ParticipatoryProcesses::Admin::ApplicationController
        layout "decidim/admin/participatory_process_group"

        helper_method :content_block, :participatory_process_group

        def edit
          enforce_permission_to :read, :process_group, process_group: participatory_process_group
          @form = form(Decidim::Admin::ContentBlockForm).from_model(content_block)
        end

        def update
          enforce_permission_to :read, :process_group, process_group: participatory_process_group
          @form = form(Decidim::Admin::ContentBlockForm).from_params(params)

          Decidim::Admin::UpdateContentBlock.call(@form, content_block, :participatory_process_group_homepage) do
            on(:ok) do
              redirect_to edit_participatory_process_group_landing_page_path(participatory_process_group)
            end
            on(:invalid) do
              render :edit
            end
          end
        end

        private

        def participatory_process_group
          @participatory_process_group ||= collection.find(params[:participatory_process_group_id])
        end

        def collection
          @collection ||= OrganizationParticipatoryProcessGroups.new(current_user.organization).query
        end

        def content_block
          @content_block ||= content_blocks.find_by(manifest_name: params[:id]) || content_block_from_manifest
        end

        def content_block_manifest
          @content_block_manifest = unused_content_block_manifests.find { |manifest| manifest.name.to_s == params[:id] }
        end

        def content_blocks
          @content_blocks ||= Decidim::ContentBlock.for_scope(
            :participatory_process_group_homepage,
            organization: current_organization
          ).where(scoped_resource_id: participatory_process_group.id)
        end

        def used_content_block_manifests
          @used_content_block_manifests ||= content_blocks.map(&:manifest_name)
        end

        def unused_content_block_manifests
          @unused_content_block_manifests ||= Decidim.content_blocks.for(:participatory_process_group_homepage).reject do |manifest|
            used_content_block_manifests.include?(manifest.name.to_s)
          end
        end

        def content_block_from_manifest
          Decidim::ContentBlock.create!(
            organization: current_organization,
            scope_name: :participatory_process_group_homepage,
            scoped_resource_id: participatory_process_group.id,
            manifest_name: params[:id]
          )
        end
      end
    end
  end
end

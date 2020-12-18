# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing the participatory process group landing
      # page
      class ParticipatoryProcessGroupLandingPageController < Decidim::ParticipatoryProcesses::Admin::ApplicationController
        helper_method :active_blocks, :inactive_blocks, :participatory_process_group

        def edit
          enforce_permission_to :update, :process_group, process_group: participatory_process_group
          render layout: "decidim/admin/participatory_process_group"
        end

        def update
          enforce_permission_to :update, :process_group, process_group: participatory_process_group
          Decidim::Admin::ReorderContentBlocks.call(current_organization, :participatory_process_group_homepage, params[:manifests], participatory_process_group.id) do
            on(:ok) do
              head :ok
            end
            on(:invalid) do
              head :bad_request
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

        def content_blocks
          @content_blocks ||= Decidim::ContentBlock.for_scope(
            :participatory_process_group_homepage,
            organization: current_organization
          ).where(scoped_resource_id: participatory_process_group.id)
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
          @unused_manifests ||= Decidim.content_blocks.for(:participatory_process_group_homepage).reject do |manifest|
            used_manifests.include?(manifest.name.to_s)
          end
        end
      end
    end
  end
end

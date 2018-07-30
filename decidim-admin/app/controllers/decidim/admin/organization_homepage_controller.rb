# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing the organization homepage
    class OrganizationHomepageController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"

      helper_method :active_blocks, :inactive_blocks

      def edit
        enforce_permission_to :update, :organization, organization: current_organization
      end

      def update
        enforce_permission_to :update, :organization, organization: current_organization
          ReorderParticipatoryProcessSteps.call(collection, params[:items_ids]) do
            on(:ok) do
              head :ok
            end
            on(:invalid) do
              head 500
            end
          end
      end

      private

      def content_blocks
        @content_blocks ||= Decidim::ContentBlock.for_scope(:homepage, organization: current_organization)
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
        @unused_manifests ||= Decidim.content_blocks.for(:homepage).select do |manifest|
          !used_manifests.include?(manifest.name.to_s)
        end
      end
    end
  end
end

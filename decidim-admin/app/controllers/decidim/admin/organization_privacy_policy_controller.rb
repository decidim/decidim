# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing the organization's privacy_policy
    class OrganizationPrivacyPolicyController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"

      helper_method :active_blocks, :inactive_blocks

      def edit
        enforce_permission_to :update, :organization, organization: current_organization
      end

      def update
        enforce_permission_to :update, :organization, organization: current_organization
        ReorderContentBlocks.call(current_organization, :privacy_policy, params[:manifests]) do
          on(:ok) do
            head :ok
          end
          on(:invalid) do
            head :bad_request
          end
        end
      end

      private

      def content_blocks
        @content_blocks ||= Decidim::ContentBlock.for_scope(:privacy_policy, organization: current_organization)
      end

      def active_blocks
        @active_blocks ||= content_blocks.published.where(manifest_name: Decidim.content_blocks.for(:privacy_policy).map(&:name))
      end

      def unpublished_blocks
        @unpublished_blocks ||= content_blocks.unpublished.where(manifest_name: Decidim.content_blocks.for(:privacy_policy).map(&:name))
      end

      def inactive_blocks
        @inactive_blocks ||= unpublished_blocks + unused_manifests
      end

      def used_manifests
        @used_manifests ||= content_blocks.map(&:manifest_name)
      end

      def unused_manifests
        @unused_manifests ||= Decidim.content_blocks.for(:privacy_policy).reject do |manifest|
          used_manifests.include?(manifest.name.to_s) # unless manifest.multiple?
        end
      end
    end
  end
end

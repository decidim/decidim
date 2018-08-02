# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing the organization homepage content blocks
    class OrganizationHomepageContentBlocksController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"

      helper_method :content_block

      def edit
        enforce_permission_to :update, :organization, organization: current_organization
      end

      def update
        enforce_permission_to :update, :organization, organization: current_organization
      end

      private

      def content_block
        @content_block ||= content_blocks.where(manifest_name: params[:id]).first ||
          unused_manifests.find { |manifest| manifest.name.to_s == params[:id] }
      end

      def content_blocks
        @content_blocks ||= Decidim::ContentBlock.for_scope(:homepage, organization: current_organization)
      end

      def used_manifests
        @used_manifests ||= content_blocks.map(&:manifest_name)
      end

      def unused_manifests
        @unused_manifests ||= Decidim.content_blocks.for(:homepage).reject do |manifest|
          used_manifests.include?(manifest.name.to_s)
        end
      end
    end
  end
end

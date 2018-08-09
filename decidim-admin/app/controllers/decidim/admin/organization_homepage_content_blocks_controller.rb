# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing the organization homepage content blocks
    class OrganizationHomepageContentBlocksController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"

      helper_method :content_block

      def edit
        enforce_permission_to :update, :organization, organization: current_organization
        @form = form(ContentBlockForm).from_model(content_block)
      end

      def update
        enforce_permission_to :update, :organization, organization: current_organization
        @form = form(ContentBlockForm).from_params(params)

        UpdateContentBlock.call(@form, content_block, :homepage) do
          on(:ok) do
            redirect_to edit_organization_homepage_path
          end
          on(:invalid) do
            render :edit
          end
        end
      end

      private

      def content_block
        @content_block ||= content_blocks.find_by(manifest_name: params[:id]) ||
                           content_block_from_manifest
      end

      def content_block_manifest
        @content_block_manifest = unused_content_block_manifests.find { |manifest| manifest.name.to_s == params[:id] }
      end

      def content_blocks
        @content_blocks ||= Decidim::ContentBlock.for_scope(:homepage, organization: current_organization)
      end

      def used_content_block_manifests
        @used_content_block_manifests ||= content_blocks.map(&:manifest_name)
      end

      def unused_content_block_manifests
        @unused_content_block_manifests ||= Decidim.content_blocks.for(:homepage).reject do |manifest|
          used_content_block_manifests.include?(manifest.name.to_s)
        end
      end

      def content_block_from_manifest
        Decidim::ContentBlock.create!(
          organization: current_organization,
          scope: :homepage,
          manifest_name: params[:id]
        )
      end
    end
  end
end

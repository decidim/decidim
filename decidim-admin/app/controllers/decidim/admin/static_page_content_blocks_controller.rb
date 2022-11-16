# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing the organization privacy policy content blocks
    class StaticPageContentBlocksController < Decidim::Admin::ApplicationController
      helper_method :content_block, :scoped_resource

      def edit
        enforce_permission_to :update, :static_page, static_page: scoped_resource
        @form = form(ContentBlockForm).from_model(content_block)
      end

      def update
        enforce_permission_to :update, :static_page, static_page: scoped_resource
        @form = form(ContentBlockForm).from_params(params)

        UpdateContentBlock.call(@form, content_block, :static_page) do
          on(:ok) do
            redirect_to edit_static_page_path scoped_resource.slug
          end

          on(:invalid) do
            edit # Sets the model to the view so that it can render the form
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
        @content_blocks ||= Decidim::ContentBlock.for_scope(:static_page, organization: current_organization).where(scoped_resource_id: params[:static_page_id])
      end

      def used_content_block_manifests
        @used_content_block_manifests ||= content_blocks.map(&:manifest_name)
      end

      def unused_content_block_manifests
        @unused_content_block_manifests ||= Decidim.content_blocks.for(:static_page).reject do |manifest|
          used_content_block_manifests.include?(manifest.name.to_s)
        end
      end

      def content_block_from_manifest
        Decidim::ContentBlock.create!(
          organization: current_organization,
          scope_name: :static_page,
          scoped_resource_id: params[:static_page_id],
          manifest_name: params[:id]
        )
      end

      def scoped_resource
        @scoped_resource ||= Decidim::StaticPage.find(content_block.scoped_resource_id)
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      module HasContentBlocks
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::LandingPage

          helper_method :content_blocks?, :active_blocks, :inactive_blocks

          def update_content_blocks
            enforce_permission_to :update, :static_page, static_page: scoped_resource

            Decidim::Admin::ReorderContentBlocks.call(current_organization, content_block_scope, params[:manifests], scoped_resource.id) do
              on(:ok) do
                head :ok
              end
              on(:invalid) do
                head :bad_request
              end
            end
          end

          private

          def content_blocks?
            return unless scoped_resource&.slug == "terms-and-conditions"

            @has_content_blocks ||= active_blocks.present? || inactive_blocks.present?
          end

          def content_block_scope
            :static_page
          end

          def scoped_resource
            @scoped_resource ||= @page || Decidim::StaticPage.find_by(id: params[:id])
          end
        end
      end
    end
  end
end

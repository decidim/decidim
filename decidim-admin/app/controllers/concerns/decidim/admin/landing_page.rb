# frozen_string_literal: true

module Decidim
  module Admin
    module LandingPage
      extend ActiveSupport::Concern
      included do
        helper_method :active_blocks, :active_content_blocks_title, :inactive_blocks,
                      :inactive_content_blocks_title, :resource_content_block_cell,
                      :resource_landing_page_content_block_path, :resource_sort_url,
                      :scoped_resource
        def edit
          enforce_permission_to_update_resource

          render "decidim/admin/shared/landing_page/edit"
        end

        def update
          enforce_permission_to_update_resource

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

        # Method to be implemented at the controller. You need to
        # return a symbol that defines the content block scope.
        # Examples of scopes could be `:homepage` or `:landing_page`.
        def content_block_scope
          raise "#{self.class.name} is expected to implement #content_block_scope"
        end

        # Method to be implemented at the controller. Defines the permissions for
        # edit and update actions.
        # For example `enforce_permission_to :manage_landing_page, :voting, voting: current_space`.
        def enforce_permission_to_update_resource
          raise "#{self.class.name} is expected to implement #enforce_permission_to_update_resource"
        end

        # Method to be implemented at the controller. Returns the URL
        # where the ordered/activated content_blocks is submitted to.
        def resource_sort_url
          raise "#{self.class.name} is expected to implement #resource_sort_url"
        end

        # Method to be implemented at the controller. Returns a string
        # with the header text for the active content_block column.
        #
        # Example: `t("landing_page.edit.active_content_blocks", scope: "decidim.votings.admin")`
        def active_content_blocks_title
          raise "#{self.class.name} is expected to implement #active_content_blocks_title"
        end

        # Method to be implemented at the controller. Returns a string
        # with the header text for the inactive content_block column.
        #
        # Example: `t("landing_page.edit.inactive_content_blocks", scope: "decidim.votings.admin")`
        def inactive_content_blocks_title
          raise "#{self.class.name} is expected to implement #inactive_content_blocks_title"
        end

        # Method to be implemented at the controller. Returns a string
        # with the cell name to be used for the drag'n'drop for each content_block.
        #
        # Example: "decidim/votings/content_block"
        def resource_content_block_cell
          raise "#{self.class.name} is expected to implement #resource_content_block_cell"
        end

        # Shared methods
        def content_blocks
          @content_blocks ||= Decidim::ContentBlock.for_scope(
            content_block_scope,
            organization: current_organization
          ).where(scoped_resource_id: scoped_resource.id)
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
          @unused_manifests ||= Decidim.content_blocks.for(content_block_scope).reject do |manifest|
            used_manifests.include?(manifest.name.to_s)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Admin
    module ContentBlocks
      module LandingPage
        extend ActiveSupport::Concern
        included do
          helper_method :active_blocks, :active_content_blocks_title, :add_content_block_text, :available_manifests,
                        :content_block_destroy_confirmation_text, :content_blocks_title, :inactive_blocks,
                        :inactive_content_blocks_title, :resource_content_block_cell, :resource_create_url,
                        :resource_sort_url
          def edit
            enforce_permission_to_update_resource

            render "decidim/admin/shared/landing_page/edit"
          end

          def update
            enforce_permission_to_update_resource

            ReorderContentBlocks.call(current_organization, content_block_scope, params[:ids_order], scoped_resource&.id) do
              on(:ok) do
                head :ok
              end
              on(:invalid) do
                head :bad_request
              end
            end
          end

          # Method that specifies the i18n scope for this controller. This can be overwritten in your controller.
          # so that you can pass a different scope to the i18n methods.
          def i18n_scope = "decidim.admin.content_blocks"

          # Method to be implemented at the controller. Returns a string
          # with the text for the title of content blocks
          #
          # i18n-tasks-use t('decidim.admin.content_blocks.edit.title')
          # Example: t("edit.title", scope: "decidim.admin.content_blocks")
          def content_blocks_title = t("edit.title", scope: i18n_scope)

          # Method to be implemented at the controller. Returns a string
          # with the text for the title of content blocks
          #
          # i18n-tasks-use t('decidim.admin.content_blocks.edit.add')
          # Example: t("edit.add", scope: "decidim.admin.content_blocks")
          def add_content_block_text = t("edit.add", scope: i18n_scope)

          # Method to be implemented at the controller. Returns a string
          # with the text for the title of content blocks
          #
          # i18n-tasks-use t('decidim.admin.content_blocks.edit.destroy_confirmation')
          # Example: t("edit.destroy_confirmation", scope: "decidim.admin.content_blocks")
          def content_block_destroy_confirmation_text = t("edit.destroy_confirmation", scope: i18n_scope)

          # Method to be implemented at the controller. Returns a string
          # with the header text for the active content_block column.
          #
          # i18n-tasks-use t('decidim.admin.content_blocks.edit.active_content_blocks')
          # Example: t("edit.active_content_blocks", scope: "decidim.admin.content_blocks")
          def active_content_blocks_title = t("edit.active_content_blocks", scope: i18n_scope)

          # Method to be implemented at the controller. Returns a string
          # with the header text for the inactive content_block column.
          #
          # i18n-tasks-use t('decidim.admin.content_blocks.edit.inactive_content_blocks')
          # Example: t("edit.inactive_content_blocks", scope: "decidim.admin.content_blocks")
          def inactive_content_blocks_title = t("edit.inactive_content_blocks", scope: i18n_scope)

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

          # Method to be implemented at the controller. Returns the URL
          # where the new content_blocks is submitted to.
          def resource_create_url
            raise "#{self.class.name} is expected to implement #resource_create_url"
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
            ).where(scoped_resource_id: scoped_resource&.id, manifest_name: available_manifests.map(&:name))
          end

          def active_blocks
            @active_blocks ||= content_blocks.published
          end

          def inactive_blocks
            @inactive_blocks ||= content_blocks.unpublished
          end

          def available_manifests
            @available_manifests ||= Decidim.content_blocks.for(content_block_scope)
          end
        end
      end
    end
  end
end

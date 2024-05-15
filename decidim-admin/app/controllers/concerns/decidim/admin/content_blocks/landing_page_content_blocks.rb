# frozen_string_literal: true

module Decidim
  module Admin
    module ContentBlocks
      module LandingPageContentBlocks
        extend ActiveSupport::Concern
        included do
          helper_method :content_block, :resource_landing_page_content_block_path, :scoped_resource, :submit_button_text

          def create
            enforce_permission_to_update_resource

            CreateContentBlock.call(current_organization, content_block_scope, params[:manifest_name], scoped_resource&.id) do
              on(:ok) do
                flash[:success] = content_block_create_success_text
              end
              on(:invalid) do
                flash[:error] = content_block_create_error_text
              end

              redirect_to edit_resource_landing_page_path
            end
          end

          def destroy
            enforce_permission_to_update_resource

            DestroyContentBlock.call(content_block) do
              on(:ok) do
                flash[:success] = content_block_destroy_success_text
              end
              on(:invalid) do
                flash[:error] = content_block_destroy_error_text
              end

              redirect_to edit_resource_landing_page_path
            end
          end

          def edit
            enforce_permission_to_update_resource
            @form = form(ContentBlockForm).from_model(content_block)

            render "decidim/admin/shared/landing_page_content_blocks/edit"
          end

          def update
            enforce_permission_to_update_resource

            @form = form(ContentBlockForm).from_params(params)

            UpdateContentBlock.call(@form, content_block, content_block_scope) do
              on(:ok) do
                redirect_to edit_resource_landing_page_path
              end
              on(:invalid) do
                render "decidim/admin/shared/landing_page_content_blocks/edit"
              end
            end
          end

          private

          # Method to be implemented at the controller. You need to
          # return a symbol that defines the content block scope.
          # Examples of scopes could be `:homepage` or `:voting_landing_page`.
          def content_block_scope
            raise "#{self.class.name} is expected to implement #content_block_scope"
          end

          # Method to be implemented at the controller. You need to
          # return an Object to filter the content blocks for the given resource.
          #
          # For example a `Voting` record.
          def scoped_resource
            raise "#{self.class.name} is expected to implement #scoped_resource"
          end

          # Method to be implemented at the controller. Defines the permissions for
          # create, destroy, edit and update actions.
          #
          # Example: `enforce_permission_to :manage_landing_page, :voting, voting: current_space`.
          def enforce_permission_to_update_resource
            raise "#{self.class.name} is expected to implement #enforce_permission_to_update_resource"
          end

          # Method to be implemented at the controller. Returns the URL
          # to the edit landing page path.
          #
          # Example: `edit_voting_landing_page_path(scoped_resource)`
          def edit_resource_landing_page_path
            raise "#{self.class.name} is expected to implement #edit_resource_landing_page_path"
          end

          # Method to be implemented at the controller. Returns the URL
          # where the ContentBlockForm is submitted.
          #
          # Example: `voting_landing_page_content_block_path(scoped_resource, params[:id])`
          def resource_landing_page_content_block_path
            raise "#{self.class.name} is expected to implement #resource_landing_page_content_block_path"
          end

          # Method that specifies the i18n scope for this controller. This can be overwritten in your controller.
          # so that you can pass a different scope to the i18n methods.
          def i18n_scope = "decidim.admin.content_blocks"

          # Method to be implemented at the controller. Returns a string
          # with the text for the submit button of the ContentBlockForm.
          #
          # i18n-tasks-use t('decidim.admin.content_blocks.edit.update')
          # Example: t("edit.update", scope: "decidim.admin.content_blocks")
          def submit_button_text = t("edit.update", scope: i18n_scope)

          # Method to be implemented at the controller. Returns a string
          # with the success text after creating a content block.
          #
          # i18n-tasks-use t('decidim.admin.content_blocks.create.success')
          # Example: t("create.success", scope: "decidim.admin.content_blocks")
          def content_block_create_success_text = t("create.success", scope: i18n_scope)

          # Method to be implemented at the controller. Returns a string
          # with the success text after creating a content block.
          #
          # i18n-tasks-use t('decidim.admin.content_blocks.create.error')
          # Example: t("create.error", scope: "decidim.admin.content_blocks")
          def content_block_create_error_text = t("create.error", scope: i18n_scope)

          # Method to be implemented at the controller. Returns a string
          # with the success text after destroying a content block.
          #
          # i18n-tasks-use t('decidim.admin.content_blocks.destroy.success')
          # Example: t("destroy.success", scope: "decidim.admin.content_blocks")
          def content_block_destroy_success_text = t("destroy.success", scope: i18n_scope)

          # Method to be implemented at the controller. Returns a string
          # with the success text after destroying a content block.
          #
          # i18n-tasks-use t('decidim.admin.content_blocks.destroy.error')
          # Example: t("destroy.error", scope: "decidim.admin.content_blocks")
          def content_block_destroy_error_text = t("destroy.error", scope: i18n_scope)

          # Shared methods
          def content_block
            @content_block ||= content_blocks.find(params[:id])
          end

          def content_blocks
            @content_blocks ||= Decidim::ContentBlock.for_scope(
              content_block_scope,
              organization: current_organization
            ).where(scoped_resource_id: scoped_resource&.id)
          end
        end
      end
    end
  end
end

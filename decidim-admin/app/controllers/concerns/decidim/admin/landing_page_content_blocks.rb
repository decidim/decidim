# frozen_string_literal: true

module Decidim
  module Admin
    module LandingPageContentBlocks
      extend ActiveSupport::Concern
      included do
        helper_method :content_block, :resource_landing_page_content_block_path,
                      :scoped_resource, :submit_button_text

        def edit
          enforce_permission_to_update_resource
          @form = form(Decidim::Admin::ContentBlockForm).from_model(content_block)

          render "decidim/admin/shared/landing_page_content_blocks/edit"
        end

        def update
          enforce_permission_to_update_resource
          @form = form(Decidim::Admin::ContentBlockForm).from_params(params)

          Decidim::Admin::UpdateContentBlock.call(@form, content_block, content_block_scope) do
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
        # edit and update actions.
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

        # Method to be implemented at the controller. Returns a string
        # with the text for the submit button of the ContentBlockForm.
        #
        # Example: t("landing_page.content_blocks.edit.update", scope: "decidim.votings.admin")
        def submit_button_text
          raise "#{self.class.name} is expected to implement #submit_button_text"
        end

        # Shared methods
        def content_block
          @content_block ||= content_blocks.find_by(manifest_name: params[:id]) || content_block_from_manifest
        end

        def content_block_manifest
          @content_block_manifest = unused_content_block_manifests.find { |manifest| manifest.name.to_s == params[:id] }
        end

        def content_blocks
          @content_blocks ||= Decidim::ContentBlock.for_scope(
            content_block_scope,
            organization: current_organization
          ).where(scoped_resource_id: scoped_resource.id)
        end

        def used_content_block_manifests
          @used_content_block_manifests ||= content_blocks.map(&:manifest_name)
        end

        def unused_content_block_manifests
          @unused_content_block_manifests ||= Decidim.content_blocks.for(content_block_scope).reject do |manifest|
            used_content_block_manifests.include?(manifest.name.to_s)
          end
        end

        def content_block_from_manifest
          Decidim::ContentBlock.create!(
            organization: current_organization,
            scope_name: content_block_scope,
            scoped_resource_id: scoped_resource.id,
            manifest_name: params[:id]
          )
        end
      end
    end
  end
end

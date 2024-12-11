# frozen_string_literal: true

module Decidim
  module Pages
    module Admin
      # This controller allows the user to update a Page.
      class PagesController < Admin::ApplicationController
        include Decidim::Admin::HasTrashableResources

        def edit
          enforce_permission_to :update, :page

          @form = form(Admin::PageForm).from_model(page)
        end

        def update
          enforce_permission_to :update, :page

          @form = form(Admin::PageForm).from_params(params)

          Admin::UpdatePage.call(@form, page) do
            on(:ok) do
              flash[:notice] = I18n.t("pages.update.success", scope: "decidim.pages.admin")
              redirect_to parent_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("pages.update.invalid", scope: "decidim.pages.admin")
              render action: "edit"
            end
          end
        end

        private

        def trashable_deleted_resource_type
          :page
        end

        def page
          @page ||= Pages::Page.find_by(component: current_component)
        end

        alias trashable_deleted_resource current_component
      end
    end
  end
end

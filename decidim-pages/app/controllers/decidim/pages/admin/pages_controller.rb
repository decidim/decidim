# frozen_string_literal: true
require "decidim/admin/components/base_controller"

module Decidim
  module Pages
    module Admin
      # This controller allows the user to update a Page.
      class PagesController < Admin::ApplicationController
        def edit
          @form = form(Admin::PageForm).from_model(page)
        end

        def update
          @form = form(Admin::PageForm).from_params(params)

          Admin::UpdatePage.call(@form, page) do
            on(:ok) do
              flash.now[:notice] = I18n.t("pages.update.success", scope: "decidim.pages.admin")
              render action: "edit"
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("pages.update.invalid", scope: "decidim.pages.admin")
              render action: "edit"
            end
          end
        end

        private

        def page
          @page ||= Pages::Page.find_by(feature: current_feature)
        end
      end
    end
  end
end

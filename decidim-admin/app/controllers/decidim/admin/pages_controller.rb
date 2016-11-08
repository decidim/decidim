# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all pages at the admin panel.
    #
    class PagesController < ApplicationController
      def index
        authorize! :index, Decidim::Page
        @pages = collection
      end

      def new
        authorize! :new, Decidim::Page
        @form = PageForm.new
      end

      def create
        authorize! :new, Decidim::Page
        @form = PageForm.from_params(params.merge(organization: current_organization))

        CreatePage.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("pages.create.success", scope: "decidim.admin")
            redirect_to pages_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("pages.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def edit
        authorize! :update, page
        @form = PageForm.from_model(page)
      end

      def update
        @page = collection.find(params[:id])
        authorize! :update, page
        @form = PageForm.from_params(params.merge(organization: current_organization))

        UpdatePage.call(page, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("pages.update.success", scope: "decidim.admin")
            redirect_to pages_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("pages.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def show
        authorize! :read, page
      end

      def destroy
        authorize! :destroy, page
        page.destroy!

        flash[:notice] = I18n.t("pages.destroy.success", scope: "decidim.admin")

        redirect_to pages_path
      end

      private

      def page
        @page ||= collection.find_by_slug(params[:id])
      end

      def collection
        current_organization.pages
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing all pages at the admin panel.
    #
    class StaticPagesController < Decidim::Admin::ApplicationController
      layout "decidim/admin/pages"

      def index
        authorize! :index, StaticPage
        @pages = collection
      end

      def new
        authorize! :new, StaticPage
        @form = form(StaticPageForm).instance
      end

      def create
        authorize! :new, StaticPage
        @form = form(StaticPageForm).from_params(form_params)

        CreateStaticPage.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("static_pages.create.success", scope: "decidim.admin")
            redirect_to static_pages_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("static_pages.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def edit
        authorize! :update, page
        @form = form(StaticPageForm).from_model(page)
      end

      def update
        @page = collection.find(params[:id])
        authorize! :update, page
        @form = form(StaticPageForm).from_params(form_params)

        UpdateStaticPage.call(page, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("static_pages.update.success", scope: "decidim.admin")
            redirect_to static_pages_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("static_pages.update.error", scope: "decidim.admin")
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

        flash[:notice] = I18n.t("static_pages.destroy.success", scope: "decidim.admin")

        redirect_to static_pages_path
      end

      private

      def form_params
        form_params = params.to_unsafe_hash
        form_params["static_page"] ||= {}
        form_params["static_page"]["organization"] = current_organization

        return form_params unless page

        form_params["static_page"]["slug"] ||= page.slug
        form_params
      end

      def page
        @page ||= collection.find_by(slug: params[:id])
      end

      def collection
        current_organization.static_pages
      end
    end
  end
end

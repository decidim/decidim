# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing all pages at the admin panel.
    #
    class StaticPagesController < Decidim::Admin::ApplicationController
      layout "decidim/admin/pages"
      before_action :tos_version_formatted, only: [:index, :edit]

      helper_method :topics

      def index
        enforce_permission_to :read, :static_page
        @topics = Decidim::StaticPageTopic.where(organization: current_organization)
        @orphan_pages = collection.where(topic: nil)
      end

      def new
        enforce_permission_to :create, :static_page
        @form = form(StaticPageForm).instance
      end

      def create
        enforce_permission_to :create, :static_page
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
        enforce_permission_to :update, :static_page, static_page: page
        @form = form(StaticPageForm).from_model(page)
      end

      def update
        @page = collection.find(params[:id])
        enforce_permission_to :update, :static_page, static_page: page
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
        enforce_permission_to :read, :static_page
      end

      def destroy
        enforce_permission_to :destroy, :static_page, static_page: page

        DestroyStaticPage.call(page, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("static_pages.destroy.success", scope: "decidim.admin")
            redirect_to static_pages_path
          end
        end
      end

      private

      def form_params
        form_params = params.to_unsafe_hash
        form_params["static_page"] ||= {}
        form_params["static_page"]["organization"] = current_organization
        form_params["static_page"]["allow_public_access"] ||= page ? page.allow_public_access : false

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

      def tos_version
        current_organization.tos_version
      end

      def tos_version_formatted
        @tos_version_formatted ||= l(tos_version, format: :short) if tos_version.present?
      end
    end
  end
end

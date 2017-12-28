# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing all navbar links at the admin panel.
    #
    class NavbarLinksController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"

      def index
        authorize! :index, Scope
        @navbar_links = Decidim::Admin::NavbarLink.all # TODO
      end

      def new
        authorize! :new, Scope
        @form = form(NavbarLinkForm).instance
      end

      def create
        authorize! :new, Scope
        @form = form(NavbarLinkForm).from_params(params)

        CreateNavbarLink.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("scopes.create.success", scope: "decidim.admin")
            redirect_to navbar_links_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("scopes.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def edit
        authorize! :update, scope
        @navbar_link = NavbarLink.find(params[:id])
        @form = form(NavbarLinkForm).from_model(scope)
      end

      def update
        authorize! :update, scope
        @form = form(NavbarLinkForm).from_params(params)

        UpdateScope.call(scope, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("scopes.update.success", scope: "decidim.admin")
            redirect_to navbar_links_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("scopes.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def destroy
        authorize! :destroy, scope
        scope.destroy!

        flash[:notice] = I18n.t("scopes.destroy.success", scope: "decidim.admin")

        redirect_to navbar_links_path
      end
    end
  end
end

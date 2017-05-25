# frozen_string_literal: true

require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all scopes at the admin panel.
    #
    class ScopesController < ApplicationController
      layout "decidim/admin/settings"

      def index
        authorize! :index, Scope
        @scopes = collection
      end

      def new
        authorize! :new, Scope
        @form = form(ScopeForm).instance
      end

      def create
        authorize! :new, Scope
        @form = form(ScopeForm).from_params(params)

        CreateScope.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("scopes.create.success", scope: "decidim.admin")
            redirect_to scopes_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("scopes.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def edit
        authorize! :update, scope
        @form = form(ScopeForm).from_model(scope)
      end

      def update
        @scope = collection.find(params[:id])
        authorize! :update, scope
        @form = form(ScopeForm).from_params(params)

        UpdateScope.call(scope, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("scopes.update.success", scope: "decidim.admin")
            redirect_to scopes_path
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

        redirect_to scopes_path
      end

      private

      def scope
        @scope ||= collection.find(params[:id])
      end

      def collection
        current_organization.scopes
      end
    end
  end
end

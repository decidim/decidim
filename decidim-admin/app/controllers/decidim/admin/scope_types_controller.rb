# frozen_string_literal: true

require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all scopes at the admin panel.
    #
    class ScopeTypesController < ApplicationController
      layout "decidim/admin/settings"
      helper_method :collection

      def index
        authorize! :index, ScopeType
      end

      def new
        authorize! :new, ScopeType
        @form = form(ScopeTypeForm).instance
      end

      def create
        authorize! :new, ScopeType
        @form = form(ScopeTypeForm).from_params(params)

        CreateScopeType.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("scope_types.create.success", scope: "decidim.admin")
            redirect_to scope_types_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("scope_types.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def edit
        authorize! :update, scope_type
        @form = form(ScopeTypeForm).from_model(scope_type)
      end

      def update
        authorize! :update, scope_type
        @form = form(ScopeTypeForm).from_params(params)

        UpdateScopeType.call(scope_type, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("scope_types.update.success", scope: "decidim.admin")
            redirect_to scope_types_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("scope_types.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def destroy
        authorize! :destroy, scope_type
        scope_type.destroy!

        flash[:notice] = I18n.t("scope_types.destroy.success", scope: "decidim.admin")

        redirect_to scope_types_path
      end

      private

      def scope_type
        @scope_type ||= collection.find(params[:id])
      end

      def collection
        current_organization.scope_types
      end
    end
  end
end

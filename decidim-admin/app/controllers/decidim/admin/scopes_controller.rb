# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing all scopes at the admin panel.
    #
    class ScopesController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"
      helper_method :scope, :parent_scope, :add_scope_path, :current_scopes_path

      def index
        authorize! :index, Scope
        @scopes = children_scopes.order("name->'#{I18n.locale}' ASC")
      end

      def new
        authorize! :new, Scope
        @form = form(ScopeForm).instance
      end

      def create
        authorize! :new, Scope
        @form = form(ScopeForm).from_params(params)
        CreateScope.call(@form, parent_scope) do
          on(:ok) do
            flash[:notice] = I18n.t("scopes.create.success", scope: "decidim.admin")
            redirect_to current_scopes_path
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
        authorize! :update, scope
        @form = form(ScopeForm).from_params(params)

        UpdateScope.call(scope, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("scopes.update.success", scope: "decidim.admin")
            redirect_to current_scopes_path
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

        redirect_to current_scopes_path
      end

      private

      def organization_scopes
        current_organization.scopes
      end

      def parent_scope
        return @parent_scope if defined?(@parent_scope)
        @parent_scope = scope ? scope.parent : organization_scopes.find_by(id: params[:scope_id])
      end

      def scope
        return @scope if defined?(@scope)
        @scope = organization_scopes.find_by(id: params[:id])
      end

      def children_scopes
        @subscopes ||= parent_scope ? parent_scope.children : organization_scopes.top_level
      end

      def current_scopes_path
        if parent_scope
          scope_scopes_path(parent_scope)
        else
          scopes_path
        end
      end
    end
  end
end

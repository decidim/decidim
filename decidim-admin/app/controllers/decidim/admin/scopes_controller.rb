# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing all scopes at the admin panel.
    #
    class ScopesController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Concerns::HasTabbedMenu

      layout "decidim/admin/settings"

      add_breadcrumb_item_from_menu :admin_settings_menu

      helper_method :scope, :parent_scope, :add_scope_path, :current_scopes_path

      def index
        enforce_permission_to :read, :scope
        field = Arel::Nodes::InfixOperation.new("->", Decidim::Scope.arel_table[:name], Arel::Nodes.build_quoted(I18n.locale))
        @scopes = children_scopes.order(Arel::Nodes::InfixOperation.new("", field, Arel.sql("ASC")))
      end

      def new
        enforce_permission_to :create, :scope
        @form = form(ScopeForm).instance
      end

      def create
        enforce_permission_to :create, :scope
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
        enforce_permission_to(:update, :scope, scope:)
        @form = form(ScopeForm).from_model(scope)
      end

      def update
        enforce_permission_to(:update, :scope, scope:)
        @form = form(ScopeForm).from_params(params)

        UpdateScope.call(@form, scope) do
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
        enforce_permission_to(:destroy, :scope, scope:)

        DestroyScope.call(scope, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("scopes.destroy.success", scope: "decidim.admin")
            redirect_to current_scopes_path
          end
        end
      end

      private

      def tab_menu_name = :admin_scopes_menu

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
        @children_scopes ||= parent_scope ? parent_scope.children : organization_scopes.top_level
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

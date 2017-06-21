# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing all scopes at the admin panel.
    #
    class ScopesController < Decidim::Admin::ApplicationController
      helper_method :scope, :parent_scope, :add_scope_path, :current_scopes_path
      layout :scope_layout

      def index
        authorize! :index, Scope
        @scopes = if parent_scope
                    parent_scope.children
                  else
                    collection.top_level
                  end
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

      def search
        authorize! :search, Scope
        scopes = if params[:term].present?
                   FreetextScopes.for(current_organization, I18n.locale, params[:term])
                 else
                   current_organization.top_scopes
                 end

        render json: { results: scopes.map { |scope| { id: scope.id, text: scope.name[I18n.locale.to_s] } } }
      end

      private

      def scope
        @scope ||= collection.find(params[:id])
      end

      def parent_scope
        @parent_scope ||= @scope ? @scope.parent : collection.find_by_id(params[:scope_id])
      end

      def collection
        current_organization.scopes
      end

      def scope_layout
        "decidim/admin/#{parent_scope ? "scope" : "settings"}"
      end

      def add_scope_path
        if parent_scope
          new_scope_scope_path(parent_scope)
        else
          new_scope_path
        end
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

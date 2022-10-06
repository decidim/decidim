# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing scopes types at the admin panel.
    #
    class ScopeTypesController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"
      helper_method :scope_types

      def index
        enforce_permission_to :read, :scope_type
      end

      def new
        enforce_permission_to :create, :scope_type
        @form = form(ScopeTypeForm).instance
      end

      def create
        enforce_permission_to :create, :scope_type
        @form = form(ScopeTypeForm).from_params(params)

        CreateScopeType.call(@form, current_user) do
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
        enforce_permission_to :update, :scope_type, scope_type: scope_type
        @form = form(ScopeTypeForm).from_model(scope_type)
      end

      def update
        enforce_permission_to :update, :scope_type, scope_type: scope_type
        @form = form(ScopeTypeForm).from_params(params)

        UpdateScopeType.call(scope_type, @form, current_user) do
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
        enforce_permission_to :destroy, :scope_type, scope_type: scope_type

        Decidim.traceability.perform_action!("delete", scope_type, current_user) do
          scope_type.destroy!
        end

        flash[:notice] = I18n.t("scope_types.destroy.success", scope: "decidim.admin")

        redirect_to scope_types_path
      end

      private

      def scope_type
        @scope_type ||= scope_types.find(params[:id])
      end

      def scope_types
        current_organization.scope_types
      end
    end
  end
end

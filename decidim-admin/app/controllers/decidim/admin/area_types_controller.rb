# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing areatypes to group areas

    class AreaTypesController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"
      helper_method :area_types

      def index
        enforce_permission_to :read, :area_type
      end

      def new
        enforce_permission_to :create, :area_type
        @form = form(AreaTypeForm).instance
      end

      def create
        enforce_permission_to :create, :area_type
        @form = form(AreaTypeForm).from_params(params)

        CreateAreaType.call(@form, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("area_types.create.success", scope: "decidim.admin")
            redirect_to area_types_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("area_types.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def edit
        enforce_permission_to :update, :area_type, area_type: area_type
        @form = form(AreaTypeForm).from_model(area_type)
      end

      def update
        enforce_permission_to :update, :area_type, area_type: area_type
        @form = form(AreaTypeForm).from_params(params)

        UpdateAreaType.call(area_type, @form, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("area_types.update.success", scope: "decidim.admin")
            redirect_to area_types_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("area_types.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def destroy
        enforce_permission_to :destroy, :area_type, area_type: area_type

        Decidim.traceability.perform_action!("delete", area_type, current_user) do
          area_type.destroy!
        end

        flash[:notice] = I18n.t("area_types.destroy.success", scope: "decidim.admin")

        redirect_to area_types_path
      end

      private

      def area_type
        @area_type ||= area_types.find(params[:id])
      end

      def area_types
        current_organization.area_types
      end
    end
  end
end

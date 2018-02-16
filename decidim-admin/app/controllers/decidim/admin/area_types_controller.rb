# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing
    # areas types at the admin panel.
    class AreaTypesController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"
      helper_method :area_types

      def index
        authorize! :index, AreaType
      end

      def new
        authorize! :new, AreaType
        @form = form(AreaTypeForm).instance
      end

      def create
        authorize! :new, AreaType
        @form = form(AreaTypeForm).from_params(params)

        CreateAreaType.call(@form) do
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
        authorize! :update, area_type
        @form = form(AreaTypeForm).from_model(area_type)
      end

      def update
        authorize! :update, area_type
        @form = form(AreaTypeForm).from_params(params)

        UpdateAreaType.call(area_type, @form) do
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
        authorize! :destroy, area_type
        area_type.destroy!

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

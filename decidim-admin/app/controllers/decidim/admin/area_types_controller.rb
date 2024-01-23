# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing areatypes to group areas

    class AreaTypesController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Concerns::HasTabbedMenu

      layout "decidim/admin/settings"

      add_breadcrumb_item_from_menu :admin_areas_menu

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
        enforce_permission_to(:update, :area_type, area_type:)
        @form = form(AreaTypeForm).from_model(area_type)
      end

      def update
        enforce_permission_to(:update, :area_type, area_type:)
        @form = form(AreaTypeForm).from_params(params)

        UpdateAreaType.call(@form, area_type) do
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
        enforce_permission_to(:destroy, :area_type, area_type:)

        Decidim::Commands::DestroyResource.call(area_type, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("area_types.destroy.success", scope: "decidim.admin")
            redirect_to area_types_path
          end
        end
      end

      private

      def tab_menu_name = :admin_areas_menu

      def area_type
        @area_type ||= area_types.find(params[:id])
      end

      def area_types
        current_organization.area_types
      end
    end
  end
end

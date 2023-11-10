# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing all areas at the admin panel.
    #
    class AreasController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Concerns::HasTabbedMenu

      layout "decidim/admin/settings"

      add_breadcrumb_item_from_menu :admin_settings_menu

      helper_method :area, :organization_areas

      def index
        enforce_permission_to :read, :area
        @areas = organization_areas
      end

      def new
        enforce_permission_to :create, :area
        @form = form(AreaForm).instance
      end

      def create
        enforce_permission_to :create, :area
        @form = form(AreaForm).from_params(params)
        CreateArea.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("areas.create.success", scope: "decidim.admin")
            redirect_to areas_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("areas.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def edit
        enforce_permission_to(:update, :area, area:)
        @form = form(AreaForm).from_model(area)
      end

      def update
        enforce_permission_to(:update, :area, area:)
        @form = form(AreaForm).from_params(params)

        UpdateArea.call(area, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("areas.update.success", scope: "decidim.admin")
            redirect_to areas_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("areas.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def destroy
        enforce_permission_to(:destroy, :area, area:)

        DestroyArea.call(area, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("areas.destroy.success", scope: "decidim.admin")
            redirect_to areas_path
          end
          on(:has_spaces) do
            flash[:alert] = I18n.t("areas.destroy.has_spaces", scope: "decidim.admin")
            redirect_to areas_path
          end
        end
      end

      private

      def tab_menu_name = :admin_areas_menu

      def organization_areas
        current_organization.areas
      end

      def area
        return @area if defined?(@area)

        @area = organization_areas.find_by(id: params[:id])
      end
    end
  end
end

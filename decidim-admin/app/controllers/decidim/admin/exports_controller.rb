# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to manage proposals in a participatory process.
    class ExportsController < Decidim::Admin::ApplicationController
      include Decidim::ComponentPathHelper

      def create
        enforce_permission_to :export, :component_data, component: component
        name = params[:id]
        ExportJob.perform_later(current_user, component, name, params[:format] || default_format, params[:resource_id].presence)

        flash[:notice] = t("decidim.admin.exports.notice")

        redirect_back(fallback_location: manage_component_path(component))
      end

      private

      def default_format
        "json"
      end

      def component
        @component ||= current_participatory_space.components.find(params[:component_id])
      end
    end
  end
end

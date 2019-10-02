# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to manage proposals in a participatory process.
    class ParticipatorySpaceExportsController < Decidim::Admin::ApplicationController
      # include Decidim::ComponentPathHelper

      def create
        # raise
        # enforce_permission_to :export, Decidim::ParticipatoryProcess
        enforce_permission_to :export, :participatory_space, participatory_space: current_participatory_space
        # enforce_permission_to :export, :component_data, component: component
        # name = params[:id]

        # ExportJob.perform_later(current_user, component, name, params[:format] || default_format)

        # flash[:notice] = t("decidim.admin.exports.notice")

        # redirect_back(fallback_location: manage_component_path(component))
      end

      private

      def default_format
        "json"
      end
    end
  end
end

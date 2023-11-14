# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to manage proposals in a participatory process.
    class ExportsController < Decidim::Admin::ApplicationController
      include Decidim::ComponentPathHelper

      def create
        enforce_permission_to(:export, :component_data, component:)
        name = params[:id]
        Decidim.traceability.perform_action!("export_component", component, current_user, { name:, format: params[:format] || default_format }) do
          ExportJob.perform_later(current_user, component, name, params[:format] || default_format, params[:resource_id].presence, export_filters)
        end

        flash[:notice] = t("decidim.admin.exports.notice")

        redirect_back(fallback_location: manage_component_path(component))
      end

      private

      def default_format
        "json"
      end

      def export_filters
        @export_filters ||= begin
          filters = params.fetch(:filters, nil)
          if !filters.is_a?(ActionController::Parameters)
            { id_in: [] }
          elsif commentable_filter?
            # in this case, we need to search through the decidim_commentable
            { decidim_commentable_id: Array(filters.fetch(:id_in, [])).compact }
          else
            { id_in: Array(filters.fetch(:id_in, [])).compact }
          end
        end.compact
      end

      def component
        @component ||= current_participatory_space.components.find(params[:component_id])
      end

      def commentable_filter?
        params[:id].match?("comments$")
      end
    end
  end
end

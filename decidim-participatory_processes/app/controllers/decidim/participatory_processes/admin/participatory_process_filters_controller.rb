# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller used to manage participatory process types for the current
      # organization
      class ParticipatoryProcessTypesController < Decidim::ParticipatoryProcesses::Admin::ApplicationController
        include Decidim::TranslatableAttributes
        before_action :set_controller_breadcrumb

        helper_method :collection, :current_participatory_process_filter
        layout "decidim/admin/participatory_process_filter"

        # GET /admin/participatory_process_filters
        def index
          enforce_permission_to :index, :participatory_process_filter
        end

        private

        def set_controller_breadcrumb
          controller_breadcrumb_items << {
            label: t("participatory_process_filters", scope: "decidim.admin.menu"),
            url: participatory_process_filters_path,
            active: false
          }

          return if params[:id].blank?

          controller_breadcrumb_items << {
            label: translated_attribute(current_participatory_process_filter.title),
            url: edit_participatory_process_filter_path(current_participatory_process_filter),
            active: true
          }
        end

        def current_participatory_process_filter
          @current_participatory_process_filter ||= collection.find(params[:id])
        end

        def collection
          @collection ||= Decidim::ParticipatoryProcessType.where(organization: current_organization)
        end
      end
    end
  end
end

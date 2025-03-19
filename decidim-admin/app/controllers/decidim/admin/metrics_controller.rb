# frozen_string_literal: true

module Decidim
  module Admin
    class MetricsController < Decidim::Admin::ApplicationController
      layout "decidim/admin/insights"

      helper_method :metrics_presenter

      before_action :set_statistic_breadcrumb_item

      def index
        enforce_permission_to :read, :metrics
      end

      private

      def metrics_presenter
        @metrics_presenter ||= Decidim::Admin::DashboardMetricChartsPresenter.new(
          summary: false,
          organization: current_organization,
          view_context:
        )
      end

      def set_statistic_breadcrumb_item
        controller_breadcrumb_items << {
          label: I18n.t("menu.statistics", scope: "decidim.admin"),
          url: decidim_admin.metrics_path,
          active: true
        }
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Admin
    class MetricsController < Decidim::Admin::ApplicationController
      helper_method :metrics_presenter

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
    end
  end
end

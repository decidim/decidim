# frozen_string_literal: true

module Decidim
  module Admin
    class ActivityGraphsController < Decidim::Admin::ApplicationController
      helper_method :activity_graphs_presenter

      def index
        enforce_permission_to :read, :activity_graph
      end

      private

      def activity_graphs_presenter
        @activity_graphs_presenter ||= Decidim::Admin::DashboardMetricChartsPresenter.new(
          summary: false,
          organization: current_organization
        )
      end
    end
  end
end

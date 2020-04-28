# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that shows a simple dashboard.
    #
    class DashboardController < Decidim::Admin::ApplicationController
      helper_method :latest_action_logs
      helper_method :metrics_presenter

      def show
        enforce_permission_to :read, :admin_dashboard
      end

      private

      def latest_action_logs
        @latest_action_logs ||= Decidim::ActionLog
                                .where(organization: current_organization)
                                .includes(:participatory_space, :user, :resource, :component, :version)
                                .for_admin
                                .order(created_at: :desc)
                                .first(5)
      end

      def metrics_presenter
        @metrics_presenter ||= Decidim::Admin::DashboardMetricChartsPresenter.new(
          summary: true,
          organization: current_organization
        )
      end
    end
  end
end

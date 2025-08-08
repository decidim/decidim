# frozen_string_literal: true

module Decidim
  module Admin
    class StatisticsController < Decidim::Admin::ApplicationController
      layout "decidim/admin/insights"

      helper_method :statistics_presenter

      before_action :set_statistic_breadcrumb_item

      def index
        enforce_permission_to :read, :statistics
      end

      private

      def statistics_presenter
        @statistics_presenter ||= Decidim::Admin::DashboardStatisticChartsPresenter.new(
          organization: current_organization,
          view_context:
        )
      end

      def set_statistic_breadcrumb_item
        controller_breadcrumb_items << {
          label: I18n.t("menu.statistics", scope: "decidim.admin"),
          url: decidim_admin.statistics_path,
          active: true
        }
      end
    end
  end
end

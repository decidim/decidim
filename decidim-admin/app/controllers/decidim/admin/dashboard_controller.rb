# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that shows a simple dashboard.
    #
    class DashboardController < Decidim::Admin::ApplicationController
      authorize_resource :admin_dashboard, class: false

      helper_method :latest_action_logs

      private

      def latest_action_logs
        @latest_action_logs ||= Decidim::ActionLog
                                .where(organization: current_organization)
                                .includes(:participatory_space, :user, :resource, :feature, :version)
                                .order(created_at: :desc)
                                .first(20)
      end
    end
  end
end

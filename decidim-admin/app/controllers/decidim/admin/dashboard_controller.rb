# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that shows a simple dashboard.
    #
    class DashboardController < Decidim::Admin::ApplicationController
      helper_method :latest_action_logs

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
                                .first(20)
      end
    end
  end
end

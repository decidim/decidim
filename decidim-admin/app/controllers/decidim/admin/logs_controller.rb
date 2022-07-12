# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that shows a simple dashboard.
    #
    class LogsController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Logs::Filterable

      helper_method :logs, :no_logs_available?

      def index
        enforce_permission_to :read, :admin_log
      end

      private

      def logs
        @logs ||= filtered_collection.order(created_at: :desc)
      end

      def no_logs_available?
        root_query.none?
      end

      def base_query
        root_query.includes(
          :participatory_space, :user, :resource, :component, :version
        )
      end

      def root_query
        Decidim::ActionLog.where(
          organization: current_organization
        ).for_admin
      end
    end
  end
end

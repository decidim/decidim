# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that shows a simple dashboard.
    #
    class LogsController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Logs::Filterable

      helper_method :logs

      def index
        enforce_permission_to :read, :admin_log
      end

      private

      def logs
        @logs ||= filtered_collection.order(created_at: :desc)
      end

      def base_query
        Decidim::ActionLog.where(
          organization: current_organization
        ).includes(
          :participatory_space, :user, :resource, :component, :version
        ).for_admin
      end
    end
  end
end

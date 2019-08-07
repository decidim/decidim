# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that shows a simple dashboard.
    #
    class LogsController < Decidim::Admin::ApplicationController
      helper_method :logs

      def index
        enforce_permission_to :read, :admin_log
      end

      private

      def logs
        @logs ||= Decidim::ActionLog
                  .where(organization: current_organization)
                  .includes(:participatory_space, :user, :resource, :component, :version)
                  .for_admin
                  .order(created_at: :desc)
                  .page(params[:page])
                  .per(20)
      end
    end
  end
end

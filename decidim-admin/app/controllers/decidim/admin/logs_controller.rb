# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that shows a simple dashboard.
    #
    class LogsController < Decidim::Admin::ApplicationController
      authorize_resource :admin_log, class: false

      helper_method :logs

      private

      def logs
        @logs ||= Decidim::ActionLog
                  .where(organization: current_organization)
                  .order(created_at: :desc)
                  .includes(:participatory_space, :user, :resource, :component, :version)
                  .page(params[:page])
                  .per(20)
      end
    end
  end
end

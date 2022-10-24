# frozen_string_literal: true

module Decidim
  module Admin
    module ManagedUsers
      # Controller that allows inspecting impersonation logs
      #
      class ImpersonationLogsController < Decidim::Admin::ApplicationController
        layout "decidim/admin/users"

        def index
          @impersonation_logs = Decidim::ImpersonationLog.where(user:).order(started_at: :desc).page(params[:page]).per(15)
        end

        private

        def user
          @user ||= current_organization.users.find(params[:impersonatable_user_id])
        end
      end
    end
  end
end

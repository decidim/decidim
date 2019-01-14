# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows batch verifying user groups by uploading a CSV file.
    class UserGroupsCsvVerificationsController < Decidim::Admin::ApplicationController
      include UserGroups

      before_action :enforce_user_groups_enabled

      layout "decidim/admin/users"

      def new
        enforce_permission_to :csv_verify, :user_group
        @form = form(UserGroupCsvVerificationForm).instance
      end

      def create
        enforce_permission_to :csv_verify, :user_group
        @form = form(UserGroupCsvVerificationForm).from_params(params)

        ProcessUserGroupVerificationCsv.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("user_group.csv_verify.success", scope: "decidim.admin")
            redirect_to decidim_admin.user_groups_path
          end

          on(:invalid) do
            flash[:alert] = I18n.t("user_group.csv_verify.invalid", scope: "decidim.admin")
            render :new
          end
        end
      end
    end
  end
end

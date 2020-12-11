# frozen_string_literal: true

module Decidim
  module Admin
    class UserSuspensionController < Decidim::Admin::ApplicationController
      layout "decidim/admin/users"

      helper_method :user

      def new
        enforce_permission_to :suspend, :admin_user

        @form = form(SuspendUserForm).from_model(user)
      end

      def create
        enforce_permission_to :suspend, :admin_user

        @form = form(SuspendUserForm).from_params(params)

        SuspendUser.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("officializations.suspend.success", scope: "decidim.admin")
          end

          on(:invalid) do
            flash[:alert] = I18n.t("officializations.suspend.error", scope: "decidim.admin")
          end
        end

        redirect_to officializations_path(q: { name_or_nickname_or_email_cont: user.name }), notice: notice
      end

      def destroy
        enforce_permission_to :suspend, :admin_user

        UnsuspendUser.call(user, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("officializations.unsuspend.success", scope: "decidim.admin")
          end

          on(:invalid) do
            flash[:alert] = I18n.t("officializations.unsuspend.error", scope: "decidim.admin")
          end
        end

        redirect_to officializations_path(q: { name_or_nickname_or_email_cont: user.name }), notice: notice
      end

      private

      def user
        @user ||= Decidim::User.find_by(
          id: params[:user_id],
          organization: current_organization
        )
      end
    end
  end
end

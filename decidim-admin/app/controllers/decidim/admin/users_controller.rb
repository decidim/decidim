# frozen_string_literal: true

require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all admins at the admin panel.
    #
    class UsersController < Admin::ApplicationController
      def index
        authorize! :index, :admin_users
        @users = collection.page(params[:page]).per(15)
      end

      def new
        authorize! :new, :admin_users
        @form = form(InviteAdminForm).instance
      end

      def create
        authorize! :new, :admin_users

        default_params = {
          organization: current_organization,
          invitation_instructions: "invite_admin",
          roles: %w(admin),
          invited_by: current_user,
          comments_notifications: true,
          replies_notifications: true
        }

        @form = form(InviteAdminForm).from_params(params.merge(default_params))

        InviteUser.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("users.create.success", scope: "decidim.admin")
            redirect_to users_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("users.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def resend_invitation
        authorize! :invite, :admin_users

        InviteUserAgain.call(user, "invite_admin") do
          on(:ok) do
            flash[:notice] = I18n.t("users.resend_invitation.success", scope: "decidim.admin")
          end

          on(:invalid) do
            flash[:alert] = I18n.t("users.resend_invitation.error", scope: "decidim.admin")
          end
        end

        redirect_to users_path
      end

      def destroy
        authorize! :destroy, :admin_users

        RemoveUserRole.call(user, "admin") do
          on(:ok) do
            flash[:notice] = I18n.t("users.destroy.success", scope: "decidim.admin")
          end

          on(:invalid) do
            flash[:alert] = I18n.t("users.destroy.error", scope: "decidim.admin")
          end
        end

        redirect_to users_path
      end

      private

      def user
        @user ||= collection.find(params[:id])
      end

      def collection
        @collection ||= current_organization.admins
      end
    end
  end
end

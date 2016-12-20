# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all admins at the admin panel.
    #
    class UsersController < Admin::ApplicationController
      def index
        authorize! :index, User
        @users = collection
      end

      def new
        authorize! :new, User
        @form = form(InviteAdminForm).instance
      end

      def create
        authorize! :new, User

        default_params = {
          organization: current_organization,
          invitation_instructions: "invite_admin",
          roles: %w(admin),
          invited_by: current_user
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
        authorize! :invite, admin

        InviteUserAgain.call(admin, "invite_admin") do
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
        authorize! :destroy, admin

        RemoveUserRole.call(admin, "admin") do
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

      def admin
        @admin ||= collection.find(params[:id])
      end

      def collection
        @collection ||= current_organization.admins
      end
    end
  end
end

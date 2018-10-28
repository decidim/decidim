# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows managing conference user roles.
      #
      class ConferenceUserRolesController < Decidim::Conferences::Admin::ApplicationController
        include Concerns::ConferenceAdmin

        def index
          enforce_permission_to :index, :conference_user_role
          @conference_user_roles = collection
        end

        def new
          enforce_permission_to :create, :conference_user_role
          @form = form(ConferenceUserRoleForm).instance
        end

        def create
          enforce_permission_to :create, :conference_user_role
          @form = form(ConferenceUserRoleForm).from_params(params)

          CreateConferenceAdmin.call(@form, current_user, current_conference) do
            on(:ok) do
              flash[:notice] = I18n.t("conference_user_roles.create.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("conference_user_roles.create.error", scope: "decidim.admin")
            end
            redirect_to conference_user_roles_path(current_conference)
          end
        end

        def edit
          @user_role = collection.find(params[:id])
          enforce_permission_to :update, :conference_user_role, user_role: @user_role
          @form = form(ConferenceUserRoleForm).from_model(@user_role.user)
        end

        def update
          @user_role = collection.find(params[:id])
          enforce_permission_to :update, :conference_user_role, user_role: @user_role
          @form = form(ConferenceUserRoleForm).from_params(params)

          UpdateConferenceAdmin.call(@form, @user_role) do
            on(:ok) do
              flash[:notice] = I18n.t("conference_user_roles.update.success", scope: "decidim.admin")
              redirect_to conference_user_roles_path(current_conference)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("conference_user_roles.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        def destroy
          @conference_user_role = collection.find(params[:id])
          enforce_permission_to :destroy, :conference_user_role, user_role: @conference_user_role

          DestroyConferenceAdmin.call(@conference_user_role, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("conference_user_roles.destroy.success", scope: "decidim.admin")
              redirect_to conference_user_roles_path(current_conference)
            end
          end
        end

        def resend_invitation
          @user_role = collection.find(params[:id])
          enforce_permission_to :invite, :conference_user_role, user_role: @user_role

          InviteUserAgain.call(@user_role.user, "invite_admin") do
            on(:ok) do
              flash[:notice] = I18n.t("users.resend_invitation.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("users.resend_invitation.error", scope: "decidim.admin")
            end
          end

          redirect_to conference_user_roles_path(current_conference)
        end

        private

        def collection
          @collection ||= Decidim::ConferenceUserRole
                          .includes(:user)
                          .where(conference: current_conference)
                          .order(:role, "decidim_users.name")
        end
      end
    end
  end
end

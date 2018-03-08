# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process user roles.
      #
      class ParticipatoryProcessUserRolesController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin

        def index
          authorize! :read, Decidim::ParticipatoryProcessUserRole
          @participatory_process_user_roles = collection
        end

        def new
          authorize! :create, Decidim::ParticipatoryProcessUserRole
          @form = form(ParticipatoryProcessUserRoleForm).instance
        end

        def create
          authorize! :create, Decidim::ParticipatoryProcessUserRole
          @form = form(ParticipatoryProcessUserRoleForm).from_params(params)

          CreateParticipatoryProcessAdmin.call(@form, current_user, current_participatory_process) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_user_roles.create.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("participatory_process_user_roles.create.error", scope: "decidim.admin")
            end
            redirect_to participatory_process_user_roles_path(current_participatory_process)
          end
        end

        def edit
          @user_role = collection.find(params[:id])
          authorize! :update, @user_role
          @form = form(ParticipatoryProcessUserRoleForm).from_model(@user_role.user)
        end

        def update
          @user_role = collection.find(params[:id])
          authorize! :update, @user_role
          @form = form(ParticipatoryProcessUserRoleForm).from_params(params)

          UpdateParticipatoryProcessAdmin.call(@form, @user_role) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_user_roles.update.success", scope: "decidim.admin")
              redirect_to participatory_process_user_roles_path(current_participatory_process)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_process_user_roles.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        def destroy
          @participatory_process_user_role = collection.find(params[:id])
          authorize! :destroy, @participatory_process_user_role

          DestroyParticipatoryProcessAdmin.call(@participatory_process_user_role, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_user_roles.destroy.success", scope: "decidim.admin")
              redirect_to participatory_process_user_roles_path(current_participatory_process)
            end
          end
        end

        def resend_invitation
          @user_role = collection.find(params[:id])
          authorize! :invite, @user_role

          InviteUserAgain.call(@user_role.user, "invite_admin") do
            on(:ok) do
              flash[:notice] = I18n.t("users.resend_invitation.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("users.resend_invitation.error", scope: "decidim.admin")
            end
          end

          redirect_to participatory_process_user_roles_path(current_participatory_process)
        end

        private

        def collection
          @collection ||= Decidim::ParticipatoryProcessUserRole
                          .includes(:user)
                          .where(participatory_process: current_participatory_process)
                          .order(:role, "decidim_users.name")
        end
      end
    end
  end
end

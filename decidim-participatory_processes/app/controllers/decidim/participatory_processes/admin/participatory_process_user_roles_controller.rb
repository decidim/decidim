# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process user roles.
      #
      class ParticipatoryProcessUserRolesController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin
        include Decidim::Admin::Officializations::Filterable

        def index
          enforce_permission_to :read, :process_user_role
          @participatory_process_user_roles = filtered_collection
        end

        def new
          enforce_permission_to :create, :process_user_role
          @form = form(ParticipatoryProcessUserRoleForm).instance
        end

        def create
          enforce_permission_to :create, :process_user_role
          @form = form(ParticipatoryProcessUserRoleForm).from_params(params)

          CreateParticipatoryProcessAdmin.call(@form, current_user, current_participatory_process) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_user_roles.create.success", scope: "decidim.admin")
              redirect_to participatory_process_user_roles_path(current_participatory_process)
            end

            on(:invalid) do
              flash[:alert] = I18n.t("participatory_process_user_roles.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          @user_role = collection.find(params[:id])
          enforce_permission_to :update, :process_user_role, process_user_role: @user_role
          @form = form(ParticipatoryProcessUserRoleForm).from_model(@user_role.user)
        end

        def update
          @user_role = collection.find(params[:id])
          enforce_permission_to :update, :process_user_role, process_user_role: @user_role
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
          enforce_permission_to :destroy, :process_user_role, process_user_role: @participatory_process_user_role

          DestroyParticipatoryProcessAdmin.call(@participatory_process_user_role, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_user_roles.destroy.success", scope: "decidim.admin")
              redirect_to participatory_process_user_roles_path(current_participatory_process)
            end
          end
        end

        def resend_invitation
          @user_role = collection.find(params[:id])
          enforce_permission_to :invite, :process_user_role, process_user_role: @user_role

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

        def search_field_predicate
          :name_or_nickname_or_email_cont
        end

        def filters
          [:invitation_accepted_at_present, :last_sign_in_at_present]
        end

        def collection
          @collection ||= Decidim::ParticipatoryProcessUserRole
                          .joins(:user)
                          .where(participatory_process: current_participatory_process) # .order(:role, "decidim_users.name")
        end
      end
    end
  end
end

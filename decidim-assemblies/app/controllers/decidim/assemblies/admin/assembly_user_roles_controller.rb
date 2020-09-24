# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assembly user roles.
      #
      class AssemblyUserRolesController < Decidim::Assemblies::Admin::ApplicationController
        include Concerns::AssemblyAdmin

        def index
          enforce_permission_to :index, :assembly_user_role
          @assembly_user_roles = collection
        end

        def new
          enforce_permission_to :create, :assembly_user_role
          @form = form(AssemblyUserRoleForm).instance
        end

        def create
          enforce_permission_to :create, :assembly_user_role
          @form = form(AssemblyUserRoleForm).from_params(params)

          CreateAssemblyAdmin.call(@form, current_user, current_assembly) do
            on(:ok) do
              flash[:notice] = I18n.t("assembly_user_roles.create.success", scope: "decidim.admin")
              redirect_to assembly_user_roles_path(current_assembly)
            end

            on(:invalid) do
              flash[:alert] = I18n.t("assembly_user_roles.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          @user_role = collection.find(params[:id])
          enforce_permission_to :update, :assembly_user_role, user_role: @user_role
          @form = form(AssemblyUserRoleForm).from_model(@user_role.user)
        end

        def update
          @user_role = collection.find(params[:id])
          enforce_permission_to :update, :assembly_user_role, user_role: @user_role
          @form = form(AssemblyUserRoleForm).from_params(params)

          UpdateAssemblyAdmin.call(@form, @user_role) do
            on(:ok) do
              flash[:notice] = I18n.t("assembly_user_roles.update.success", scope: "decidim.admin")
              redirect_to assembly_user_roles_path(current_assembly)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("assembly_user_roles.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        def destroy
          @assembly_user_role = collection.find(params[:id])
          enforce_permission_to :destroy, :assembly_user_role, user_role: @assembly_user_role

          DestroyAssemblyAdmin.call(@assembly_user_role, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("assembly_user_roles.destroy.success", scope: "decidim.admin")
              redirect_to assembly_user_roles_path(current_assembly)
            end
          end
        end

        def resend_invitation
          @user_role = collection.find(params[:id])
          enforce_permission_to :invite, :assembly_user_role, user_role: @user_role

          InviteUserAgain.call(@user_role.user, "invite_admin") do
            on(:ok) do
              flash[:notice] = I18n.t("users.resend_invitation.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("users.resend_invitation.error", scope: "decidim.admin")
            end
          end

          redirect_to assembly_user_roles_path(current_assembly)
        end

        private

        def collection
          @collection ||= Decidim::AssemblyUserRole
                          .includes(:user)
                          .where(assembly: current_assembly)
                          .order(:role, "decidim_users.name")
        end
      end
    end
  end
end

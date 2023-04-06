# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assembly user roles.
      #
      class AssemblyUserRolesController < Decidim::Assemblies::Admin::ApplicationController
        include Concerns::AssemblyAdmin
        include Decidim::Admin::ParticipatorySpace::UserRoleController

        def authorization_scope = :assembly_user_role

        def resource_form = form(AssemblyUserRoleForm)

        def space_index_path = assembly_user_roles_path(current_assembly)

        def i18n_scope = "decidim.admin.assembly_user_roles"

        def create
          enforce_permission_to :create, authorization_scope
          @form = resource_form.from_params(params)

          CreateAssemblyAdmin.call(@form, current_user, current_assembly) do
            on(:ok) do
              flash[:notice] = I18n.t("create.success", scope: i18n_scope)
              redirect_to space_index_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("create.error", scope: i18n_scope)
              render :new
            end
          end
        end

        def update
          @user_role = collection.find(params[:id])
          enforce_permission_to :update, authorization_scope, user_role: @user_role
          @form = resource_form.from_params(params)

          UpdateAssemblyAdmin.call(@form, @user_role) do
            on(:ok) do
              flash[:notice] = I18n.t("update.success", scope: i18n_scope)
              redirect_to space_index_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("update.error", scope: i18n_scope)
              render :edit
            end
          end
        end

        def destroy
          @user_role = collection.find(params[:id])
          enforce_permission_to :destroy, authorization_scope, user_role: @user_role

          DestroyAssemblyAdmin.call(@user_role, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("destroy.success", scope: i18n_scope)
              redirect_to space_index_path
            end
          end
        end

        private

        def collection
          @collection ||= Decidim::AssemblyUserRole
                          .joins(:user)
                          .where(assembly: current_assembly)
        end
      end
    end
  end
end

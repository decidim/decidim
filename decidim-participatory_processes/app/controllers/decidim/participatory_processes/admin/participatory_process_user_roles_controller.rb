# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process user roles.
      #
      class ParticipatoryProcessUserRolesController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin
        include Decidim::Admin::Officializations::Filterable
        include Decidim::Admin::ParticipatorySpace::UserRoleController

        def authorization_scope = :process_user_role

        def resource_form = form(ParticipatoryProcessUserRoleForm)

        def space_index_path = participatory_process_user_roles_path(current_participatory_process)

        def i18n_scope = "decidim.admin"

        def create
          enforce_permission_to :create, authorization_scope
          @form = resource_form.from_params(params)

          CreateParticipatoryProcessAdmin.call(@form, current_user, current_participatory_process) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_user_roles.create.success", scope: i18n_scope)
              redirect_to space_index_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("participatory_process_user_roles.create.error", scope: i18n_scope)
              render :new
            end
          end
        end

        def update
          @user_role = collection.find(params[:id])
          enforce_permission_to :update, authorization_scope, user_role: @user_role
          @form = resource_form.from_params(params)

          UpdateParticipatoryProcessAdmin.call(@form, @user_role) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_user_roles.update.success", scope: i18n_scope)
              redirect_to space_index_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_process_user_roles.update.error", scope: i18n_scope)
              render :edit
            end
          end
        end

        def destroy
          @user_role = collection.find(params[:id])
          enforce_permission_to :destroy, authorization_scope, user_role: @user_role

          DestroyParticipatoryProcessAdmin.call(@user_role, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_user_roles.destroy.success", scope: i18n_scope)
              redirect_to space_index_path
            end
          end
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
                          .where(participatory_process: current_participatory_process)
        end
      end
    end
  end
end

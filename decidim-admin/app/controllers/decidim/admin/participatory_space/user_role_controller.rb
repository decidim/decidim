# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Admin
    module ParticipatorySpace
      class UserRoleController < Decidim::Admin::ApplicationController
        include Decidim::Admin::Officializations::Filterable

        helper_method :filtered_collection

        def index
          enforce_permission_to :index, authorization_scope
          @user_roles = filtered_collection
        end

        def new
          enforce_permission_to :create, authorization_scope
          @form = resource_form.instance
        end

        def edit
          @user_role = collection.find(params[:id])
          enforce_permission_to :update, authorization_scope, user_role: @user_role
          @form = resource_form.from_model(@user_role.user)
        end

        def create
          enforce_permission_to :create, authorization_scope
          @form = resource_form.from_params(params)

          create_command.call(@form, current_participatory_space, event_class:, event:, role_class:) do
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

          update_command.call(@form, @user_role, event_class:, event:) do
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

          destroy_command.call(@user_role, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("destroy.success", scope: i18n_scope)
              redirect_to space_index_path
            end
          end
        end

        def resend_invitation
          @user_role = collection.find(params[:id])
          enforce_permission_to :invite, authorization_scope, user_role: @user_role

          InviteUserAgain.call(@user_role.user, "invite_admin") do
            on(:ok) do
              flash[:notice] = I18n.t("users.resend_invitation.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("users.resend_invitation.error", scope: "decidim.admin")
            end
          end

          redirect_to space_index_path
        end

        private

        def event = raise NotImplementedError, "Event method must be implemented for #{self.class.name}"

        def event_class = raise NotImplementedError, "Event class method must be implemented for #{self.class.name}"

        def collection
          @collection ||= role_class.joins(:user).for_space(current_participatory_space)
        end

        def destroy_command = Decidim::Admin::ParticipatorySpace::DestroyAdmin

        def update_command = Decidim::Admin::ParticipatorySpace::UpdateAdmin

        def create_command = Decidim::Admin::ParticipatorySpace::CreateAdmin

        def search_field_predicate
          :name_or_nickname_or_email_cont
        end

        def filters
          [:invitation_accepted_at_present, :last_sign_in_at_present]
        end
      end
    end
  end
end

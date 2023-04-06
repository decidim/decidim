# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Admin
    module ParticipatorySpace
      module UserRoleController
        extend ActiveSupport::Concern

        included do
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

            create_command.call(@form, current_user, current_participatory_space) do
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

            update_command.call(@form, @user_role) do
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
end

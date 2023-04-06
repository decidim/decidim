# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Admin
    module ParticipatorySpace
      module UserRoleController
        extend ActiveSupport::Concern

        included do
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
        end
      end
    end
  end
end

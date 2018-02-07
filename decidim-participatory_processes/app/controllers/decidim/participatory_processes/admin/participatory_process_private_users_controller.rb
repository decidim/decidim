# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process user roles.
      #
      class ParticipatoryProcessPrivateUsersController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin

        def index
          authorize! :read, Decidim::ParticipatoryProcessPrivateUser
          @participatory_process_private_users = collection
        end

        def new
          authorize! :create, Decidim::ParticipatoryProcessPrivateUser
          @form = form(ParticipatoryProcessPrivateUserForm).instance
        end

        def create
          authorize! :create, Decidim::ParticipatoryProcessPrivateUser
          @form = form(ParticipatoryProcessPrivateUserForm).from_params(params)

          CreateParticipatoryProcessPrivateUser.call(@form, current_user, current_participatory_process) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_process_user_roles.create.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("participatory_process_user_roles.create.error", scope: "decidim.admin")
            end
            redirect_to participatory_process_private_users_path(current_participatory_process)
          end
        end

        def destroy
          @private_user = collection.find(params[:id])
          authorize! :destroy, @private_user
          @private_user.destroy!

          flash[:notice] = I18n.t("participatory_process_private_users.destroy.success", scope: "decidim.admin")

          redirect_to participatory_process_private_users_path(@private_user.participatory_process)
        end

        def resend_invitation
          @private_user = collection.find(params[:id])
          authorize! :invite, @private_user

          InviteUserAgain.call(@private_user.user, "invite_private_user") do
            on(:ok) do
              flash[:notice] = I18n.t("users.resend_invitation.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("users.resend_invitation.error", scope: "decidim.admin")
            end
          end

          redirect_to participatory_process_private_users_path(current_participatory_process)
        end

        private

        def collection
          @collection ||= Decidim::ParticipatoryProcessPrivateUser
                          .includes(:user)
                          .where(participatory_process: current_participatory_process)
        end
      end
    end
  end
end

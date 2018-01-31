# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing participatory process user roles.
      #
      class AssemblyPrivateUsersController < Decidim::Admin::ApplicationController
        include Concerns::AssemblyAdmin

        def index
          authorize! :read, Decidim::AssemblyPrivateUser
          @assembly_private_users = collection
        end

        def new
          authorize! :create, Decidim::AssemblyPrivateUser
          @form = form(AssemblyPrivateUserForm).instance
        end

        def create
          authorize! :create, Decidim::AssemblyPrivateUser
          @form = form(AssemblyPrivateUserForm).from_params(params)

          CreateAssemblyAdmin.call(@form, current_user, current_assembly) do
            on(:ok) do
              flash[:notice] = I18n.t("assembly_private_users.create.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("assembly_private_users.create.error", scope: "decidim.admin")
            end
            redirect_to assembly_private_users_path(current_assembly)
          end
        end

        def destroy
          @private_user = collection.find(params[:id])
          authorize! :destroy, @private_user
          @private_user.destroy!

          flash[:notice] = I18n.t("assembly_private_users.destroy.success", scope: "decidim.admin")

          redirect_to assembly_private_users_path(@private_user.assembly)
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

          redirect_to assembly_private_users_path(current_assembly)
        end

        private

        def collection
          @collection ||= Decidim::AssemblyPrivateUser
                          .includes(:user)
                          .where(assembly: current_participatory_space)
        end
      end
    end
  end
end

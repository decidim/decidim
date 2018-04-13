# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing managed users at the admin panel.
    #
    class ManagedUsersController < Decidim::Admin::ApplicationController
      layout "decidim/admin/users"

      helper_method :available_authorization_handlers

      def new
        authorize! :new, :managed_users

        @form = form(ImpersonateUserForm).from_params(
          authorization: Decidim::AuthorizationHandler.handler_for(handler_name)
        )
      end

      def create
        authorize! :create, :managed_users

        @form = form(ImpersonateUserForm).from_params(
          user: user,
          authorization: Decidim::AuthorizationHandler.handler_for(
            handler_name,
            params[:impersonate_user][:authorization].merge(user: user)
          )
        )

        ImpersonateUser.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("managed_users.create.success", scope: "decidim.admin")
            redirect_to decidim.root_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("managed_users.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      private

      def user
        Decidim::User.find_or_initialize_by(
          organization: current_organization,
          managed: true,
          name: params[:impersonate_user][:name]
        ) do |u|
          u.admin = false
          u.tos_agreement = true
        end
      end

      def handler_name
        available_authorization_handlers.first.name
      end

      def available_authorization_handlers
        Decidim::Verifications::Adapter.from_collection(
          current_organization.available_authorization_handlers
        )
      end
    end
  end
end

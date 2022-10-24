# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows impersonating managed users at the admin panel.
    #
    class ImpersonationsController < Decidim::Admin::ApplicationController
      layout "decidim/admin/users"

      helper_method :available_authorization_handlers,
                    :other_available_authorizations,
                    :creating_managed_user?

      def new
        enforce_permission_to :impersonate, :impersonatable_user, user: user

        @form = form(ImpersonateUserForm).from_params(
          user:,
          handler_name:,
          authorization: Decidim::AuthorizationHandler.handler_for(
            handler_name,
            user:
          )
        )
      end

      def create
        enforce_permission_to :impersonate, :impersonatable_user, user: user

        @form = form(ImpersonateUserForm).from_params(
          user:,
          handler_name:,
          reason: params[:impersonate_user][:reason],
          authorization: Decidim::AuthorizationHandler.handler_for(
            handler_name,
            params[:impersonate_user][:authorization].merge(user:)
          )
        )

        ImpersonateUser.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("impersonations.create.success", scope: "decidim.admin") if creating_managed_user?
            redirect_to decidim.root_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("impersonations.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def close_session
        CloseSessionManagedUser.call(user, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("impersonations.close_session.success", scope: "decidim.admin")
            redirect_to impersonatable_users_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("impersonations.close_session.error", scope: "decidim.admin")
            redirect_to decidim.root_path
          end
        end
      end

      private

      def user
        @user ||= if creating_managed_user?
                    existing_managed_user || new_managed_user
                  else
                    current_organization.users.find(params[:impersonatable_user_id])
                  end
      end

      def existing_managed_user
        handler = Decidim::AuthorizationHandler.handler_for(
          handler_name,
          params.dig(:impersonate_user, :authorization)
        )
        return nil unless handler.unique_id

        existing_authorization = Authorization.find_by(
          name: handler_name,
          unique_id: handler.unique_id
        )
        return nil unless existing_authorization
        return nil unless existing_authorization.user.managed?

        existing_authorization.user
      end

      def new_managed_user
        Decidim::User.new(
          organization: current_organization,
          managed: true,
          name: params.dig(:impersonate_user, :name)
        ) do |u|
          u.nickname = Decidim::UserBaseEntity.nicknamize(u.name, organization: current_organization)
          u.admin = false
          u.tos_agreement = true
        end
      end

      def creating_managed_user?
        params[:impersonatable_user_id] == "new_managed_user"
      end

      def handler_name
        authorization = params.dig(:impersonate_user, :authorization)
        return available_authorization_handlers.first.name unless authorization

        authorization[:handler_name]
      end

      def other_available_authorizations
        return [] if available_authorization_handlers.size == 1

        other_available_authorization_handlers.map do |authorization_handler|
          Decidim::AuthorizationHandler.handler_for(authorization_handler.name)
        end
      end

      def other_available_authorization_handlers
        Decidim::Verifications::Adapter.from_collection(
          current_organization.available_authorization_handlers - [handler_name]
        )
      end

      def available_authorization_handlers
        Decidim::Verifications::Adapter.from_collection(
          current_organization.available_authorization_handlers
        )
      end
    end
  end
end

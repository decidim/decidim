# frozen_string_literal: true

module Decidim
  module Admin
    module ManagedUsers
      # Controller that allows impersonating managed users at the admin panel.
      #
      class ImpersonationsController < Decidim::Admin::ApplicationController
        layout "decidim/admin/users"

        helper_method :available_authorization_handlers,
                      :other_available_authorizations

        skip_authorization_check only: [:close_session]

        def index
          authorize! :index, :impersonations
          @users = collection.page(params[:page]).per(15)
        end

        def new
          authorize! :impersonate, user

          @form = form(ImpersonateUserForm).from_params(
            user: user,
            handler_name: handler_name,
            authorization: Decidim::AuthorizationHandler.handler_for(
              handler_name,
              user: user
            )
          )
        end

        def create
          authorize! :impersonate, user

          @form = form(ImpersonateUserForm).from_params(
            user: user,
            handler_name: handler_name,
            reason: params[:impersonate_user][:reason],
            authorization: Decidim::AuthorizationHandler.handler_for(
              handler_name,
              params[:impersonate_user][:authorization].merge(user: user)
            )
          )

          ImpersonateUser.call(@form) do
            on(:ok) do
              redirect_to decidim.root_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("managed_users.impersonate.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def close_session
          CloseSessionManagedUser.call(user, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("managed_users.close_session.success", scope: "decidim.admin")
              redirect_to impersonations_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("managed_users.close_session.error", scope: "decidim.admin")
              redirect_to decidim.root_path
            end
          end
        end

        private

        def collection
          @collection ||= current_organization.users
        end

        def user
          @user ||= current_organization.users.find(params[:managed_user_id])
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
end

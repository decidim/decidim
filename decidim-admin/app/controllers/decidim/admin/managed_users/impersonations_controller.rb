# frozen_string_literal: true

module Decidim
  module Admin
    module ManagedUsers
      # Controller that allows impersonating managed users at the admin panel.
      #
      class ImpersonationsController < Decidim::Admin::ApplicationController
        layout "decidim/admin/users"

        helper_method :available_authorization_handlers,
                      :select_authorization_handler_step?

        skip_authorization_check only: [:close_session]

        def index
          authorize! :index, :impersonations
          @users = collection.page(params[:page]).per(15)
        end

        def new
          authorize! :impersonate, user

          unless select_authorization_handler_step?
            @form = form(ImpersonateUserForm).from_params(
              authorization: {
                handler_name: handler_name
              }
            )
          end
        end

        def create
          authorize! :impersonate, user

          @form = form(ImpersonateUserForm).from_params(params)

          ImpersonateUser.call(@form, user) do
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

        def select_authorization_handler_step?
          handler_name.blank?
        end

        def collection
          @collection ||= current_organization.users
        end

        def user
          @user ||= current_organization.users.find(params[:managed_user_id])
        end

        def handler_name
          return authorization&.name if more_than_one_authorization_handler?

          available_authorization_handlers.first.name
        end

        def available_authorization_handlers
          Decidim::Verifications::Adapter.from_collection(
            current_organization.available_authorization_handlers
          )
        end

        def more_than_one_authorization_handler?
          available_authorization_handlers.length > 1
        end

        def authorization
          @authorization ||= Authorization.find_by(user: user)
        end
      end
    end
  end
end

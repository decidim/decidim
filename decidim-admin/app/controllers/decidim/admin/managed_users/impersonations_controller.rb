# frozen_string_literal: true

require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    module ManagedUsers
      # Controller that allows managing managed users at the admin panel.
      #
      class ImpersonationsController < Admin::ApplicationController
        layout "decidim/admin/users"

        helper_method :more_than_one_authorization?

        def new
          authorize! :impersonate, user

          if handler_name.present?
            @form = form(ImpersonateManagedUserForm).from_params(
              authorization: {
                handler_name: handler_name
              }
            )
          end
        end

        def create
          authorize! :impersonate, user

          @form = form(ImpersonateManagedUserForm).from_params(params)

          ImpersonateManagedUser.call(@form, user, current_user) do
            on(:ok) do
              redirect_to decidim.root_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("managed_users.impersonate.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        private

        def user
          @user ||= current_organization.users.managed.find(params[:managed_user_id])
        end

        def handler_name
          return params[:handler_name] if more_than_one_authorization?
          available_authorizations.first
        end

        def available_authorizations
          current_organization.available_authorizations.map(&:underscore)
        end

        def more_than_one_authorization?
          available_authorizations.length > 1
        end
      end
    end
  end
end

# frozen_string_literal: true

require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing managed users at the admin panel.
    #
    class ManagedUsersController < Admin::ApplicationController
      layout "decidim/admin/users"

      helper_method :available_authorizations, :more_than_one_authorization?

      def index
        authorize! :index, :managed_users
        @managed_users = collection.page(params[:page]).per(15)
      end

      def new
        authorize! :new, :managed_users

        if handler_name.present?
          @form = form(ManagedUserForm).from_params(
            authorization: {
              handler_name: handler_name
            }
          )
        end
      end

      def create
        authorize! :create, :managed_users

        @form = form(ManagedUserForm).from_params(params)

        CreateManagedUser.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("managed_users.create.success", scope: "decidim.admin")
            redirect_to managed_users_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("managed_users.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      private

      def collection
        @collection ||= current_organization.users.managed
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

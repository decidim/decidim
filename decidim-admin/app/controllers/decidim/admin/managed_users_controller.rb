# frozen_string_literal: true

require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing managed users at the admin panel.
    #
    class ManagedUsersController < Admin::ApplicationController
      layout "decidim/admin/users"

      helper_method :available_authorization_handlers,
                    :more_than_one_authorization_handler?,
                    :select_authorization_handler_step?

      def index
        authorize! :index, :managed_users
        @managed_users = collection.page(params[:page]).per(15)
      end

      def new
        authorize! :new, :managed_users

        unless select_authorization_handler_step?
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
            redirect_to decidim.root_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("managed_users.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      private

      def select_authorization_handler_step?
        handler_name.blank? && params[:managed_user].blank?
      end

      def collection
        @collection ||= current_organization.users.managed
      end

      def handler_name
        return params[:handler_name] if more_than_one_authorization_handler?
        available_authorization_handlers.first.name
      end

      def available_authorization_handlers
        Verifications::Adapter.from_collection(
          current_organization.available_authorizations & Decidim.authorization_handlers.map(&:name)
        )
      end

      def more_than_one_authorization_handler?
        available_authorization_handlers.length > 1
      end
    end
  end
end

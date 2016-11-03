# frozen_string_literal: true
require_dependency "decidim/application_controller"

module Decidim
  # This controller allows users to create and destroy their authorizations. It
  # shouldn't be necessary to expand it to add new authorization schemes.
  class AuthorizationsController < ApplicationController
    helper_method :handler, :handlers
    before_action :valid_handler, only: [:new, :create]
    before_action :only_one_handler?, only: [:index]

    def new
      authorize! current_user, Authorization
    end

    def index
      authorize! current_user, Authorization
    end

    def create
      authorize! current_user, Authorization

      AuthorizeUser.call(handler) do
        on(:ok) do
          flash[:notice] = t("authorizations.create.success", scope: "decidim")
          redirect_to account_path
        end

        on(:invalid) do
          flash[:alert] = t("authorizations.create.error", scope: "decidim")
          render action: :new
        end
      end
    end

    def destroy
      @authorization = current_user.authorizations.find(params[:id])
      authorize! current_user, @authorization

      @authorization.destroy
      flash[:notice] = t("authorizations.destroy.success", scope: "decidim")
      redirect_to account_path
    end

    def handler
      @handler ||= AuthorizationHandler.handler_for(handler_name, handler_params)
    end

    def handlers
      @handlers ||= Decidim.authorization_handlers
    end

    protected

    def handler_params
      (params[:authorization_handler] || {}).merge(user: current_user)
    end

    def handler_name
      params[:handler] || params[:authorization_handler][:handler_name]
    end

    def valid_handler
      return true if handler

      logger.warn "Invalid authorization handler given: #{handler_name} doesn't"\
        "exist or you haven't added it to `Decidim.authorization_handlers`"

      redirect_to(account_path) && (return false)
    end

    def only_one_handler?
      redirect_to(action: :new, handler: handlers.first.handler_name) && return if handlers.length == 1
    end
  end
end

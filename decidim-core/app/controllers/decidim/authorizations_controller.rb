# frozen_string_literal: true
require_dependency "decidim/application_controller"

module Decidim
  # This controller allows users to create and destroy their authorizations. It
  # shouldn't be necessary to expand it to add new authorization schemes.
  class AuthorizationsController < ApplicationController
    helper_method :handler, :handlers
    before_action :valid_handler, only: [:new, :create]

    include Decidim::UserProfile

    layout "layouts/decidim/user_profile", only: [:index]

    def new; end

    def index
      @authorizations = current_user.authorizations
    end

    def first_login
      redirect_to(action: :new, handler: handlers.first.handler_name) if handlers.length == 1
    end

    def create
      authorize! :create, @authorization

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
      authorize! :destroy, @authorization

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

    def handlers
      @handlers ||= available_authorization_handlers.reject do |handler|
        authorized_handlers.include?(handler.handler_name)
      end
    end

    def authorized_handlers
      current_user.authorizations.map(&:name)
    end
  end
end

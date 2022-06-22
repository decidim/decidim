# frozen_string_literal: true

module Decidim
  module Verifications
    # This controller allows users to create and destroy their authorizations. It
    # shouldn't be necessary to expand it to add new authorization schemes.
    class AuthorizationsController < Verifications::ApplicationController
      helper_method :handler, :unauthorized_methods, :authorization_method, :authorization
      before_action :valid_handler, only: [:new, :create]

      include Decidim::UserProfile
      include Decidim::Verifications::Renewable
      helper Decidim::DecidimFormHelper
      helper Decidim::CtaButtonHelper
      helper Decidim::AuthorizationFormHelper
      helper Decidim::TranslationsHelper

      layout "layouts/decidim/user_profile", only: [:index]

      def new; end

      def index
        @granted_authorizations = granted_authorizations
        @pending_authorizations = pending_authorizations
      end

      def first_login
        if unauthorized_methods.length == 1
          redirect_to(
            action: :new,
            handler: unauthorized_methods.first.name,
            redirect_url: decidim.account_path
          )
        end
      end

      def create
        AuthorizeUser.call(handler, current_organization) do
          on(:ok) do
            flash[:notice] = t("authorizations.create.success", scope: "decidim.verifications")
            redirect_to redirect_url || authorizations_path
          end

          on(:transferred) do
            flash[:notice] = t("authorizations.create.transferred", scope: "decidim.verifications")
            redirect_to redirect_url || authorizations_path
          end

          on(:invalid) do
            flash[:alert] = t("authorizations.create.error", scope: "decidim.verifications")
            render action: :new
          end
        end
      end

      protected

      def authorization_method(authorization)
        return unless authorization

        Decidim::Verifications::Adapter.from_element(authorization.name)
      end

      def handler
        @handler ||= Decidim::AuthorizationHandler.handler_for(handler_name, handler_params)
      end

      def handler_params
        (params[:authorization_handler] || {}).merge(user: current_user)
      end

      def handler_name
        params[:handler] || params.dig(:authorization_handler, :handler_name)
      end

      def valid_handler
        return true if handler

        msg = <<-MSG
        Invalid authorization handler given: #{handler_name} doesn't
        exist or you haven't added it to `Decidim.authorization_handlers.

        Make sure this name matches with your registrations:\n\n
        Decidim::Verifications.register_workflow(:#{handler_name}) do
          ...
        end
        MSG

        raise msg if Rails.env.development?

        logger.warn msg
        redirect_to(authorizations_path) && (return false)
      end

      def unauthorized_methods
        @unauthorized_methods ||= available_verification_workflows.reject do |handler|
          active_authorization_methods.include?(handler.key)
        end
      end

      def active_authorization_methods
        Authorizations.new(organization: current_organization, user: current_user).pluck(:name)
      end

      def granted_authorizations
        Authorizations.new(organization: current_organization, user: current_user, granted: true)
      end

      def pending_authorizations
        Authorizations.new(organization: current_organization, user: current_user, granted: false)
      end

      def store_current_location
        return if redirect_url.blank? || !request.format.html?

        store_location_for(:user, redirect_url)
      end

      private

      def authorization
        @authorization ||= Decidim::Authorization.find_by(
          user: current_user,
          name: handler_name
        )
      end
    end
  end
end

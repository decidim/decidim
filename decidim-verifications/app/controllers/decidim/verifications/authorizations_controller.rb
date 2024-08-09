# frozen_string_literal: true

module Decidim
  module Verifications
    # This controller allows users to create and destroy their authorizations. It
    # should not be necessary to expand it to add new authorization schemes.
    class AuthorizationsController < Verifications::ApplicationController
      helper_method :handler, :unauthorized_methods, :authorization_method, :authorization, :onboarding_manager,
                    :granted_authorizations, :pending_authorizations, :active_authorization_methods

      before_action :valid_handler, only: [:new, :create]

      include Decidim::UserProfile
      include Decidim::HtmlSafeFlash
      include Decidim::Verifications::Renewable
      helper Decidim::DecidimFormHelper
      helper Decidim::CtaButtonHelper
      helper Decidim::AuthorizationFormHelper
      helper Decidim::TranslationsHelper

      layout "layouts/decidim/authorizations", except: [:index, :first_login]

      def new; end

      def index; end

      # TODO: rename to onboarding?
      def first_login
        return redirect_to authorizations_path unless onboarding_manager.valid?

        if onboarding_manager.finished_verifications?(active_authorization_methods)
          flash[:notice] = t("authorizations.first_login.completed_verifications", scope: "decidim.verifications")
          redirect_to ResourceLocatorPresenter.new(onboarding_manager.model).url

          onboarding_manager.remove_pending_action!
        end
      end

      def create
        AuthorizeUser.call(handler, current_organization) do
          on(:ok) do
            flash[:notice] = t("authorizations.create.success", scope: "decidim.verifications")
            redirect_to redirect_url || authorizations_path
          end

          on(:transferred) do |transfer|
            message = t("authorizations.create.success", scope: "decidim.verifications")
            if transfer.records.any?
              flash[:html_safe] = true
              message = <<~HTML
                <p>#{CGI.escapeHTML(message)}</p>
                <p>#{CGI.escapeHTML(t("authorizations.create.transferred", scope: "decidim.verifications"))}</p>
                #{transfer.presenter.records_list_html}
              HTML
            end

            flash[:notice] = message
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

      def onboarding_manager
        @onboarding_manager ||= Decidim::OnboardingManager.new(current_user)
      end

      def valid_handler
        return true if handler

        msg = <<-MSG
        Invalid authorization handler given: #{handler_name} does not
        exist or you have not added it to `Decidim.authorization_handlers.

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
        @active_authorization_methods ||= Authorizations.new(organization: current_organization, user: current_user).pluck(:name)
      end

      def granted_authorizations
        @granted_authorizations ||= Authorizations.new(organization: current_organization, user: current_user, granted: true)
      end

      def pending_authorizations
        @pending_authorizations ||= Authorizations.new(organization: current_organization, user: current_user, granted: false)
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

# frozen_string_literal: true

module Decidim
  module Verifications
    # This controller allows users to create and destroy their authorizations. It
    # should not be necessary to expand it to add new authorization schemes.
    class AuthorizationsController < Verifications::ApplicationController
      helper_method :handler, :unauthorized_methods, :authorization_method, :authorization,
                    :granted_authorizations, :pending_authorizations, :active_authorization_methods

      before_action :valid_handler, :authorize_handler, only: [:new, :create]
      before_action :set_ephemeral_user, only: :renew_onboarding_data

      include Decidim::UserProfile
      include Decidim::HtmlSafeFlash
      include Decidim::Verifications::Renewable
      helper Decidim::DecidimFormHelper
      helper Decidim::AuthorizationFormHelper
      helper Decidim::TranslationsHelper

      layout "layouts/decidim/authorizations", except: [:index, :onboarding_pending]

      def new; end

      def index; end

      def onboarding_pending
        return redirect_back(fallback_location: authorizations_path) unless onboarding_manager.valid?

        authorizations = action_authorized_to(onboarding_manager.action, **onboarding_manager.action_authorized_resources)

        authorization_status = authorizations.global_code
        if authorizations.single_authorization_required?
          flash.keep
          return redirect_to(authorizations.statuses.first.current_path(redirect_url: decidim_verifications.onboarding_pending_authorizations_path))
        end
        return unless onboarding_manager.finished_verifications?(active_authorization_methods) || authorization_status == :unauthorized

        if authorization_status == :unauthorized
          flash[:alert] = t("authorizations.onboarding_pending.unauthorized", scope: "decidim.verifications", action: onboarding_manager.action_text.downcase)
        elsif current_user.ephemeral?
          flash[:notice] = t("ephemeral_authorized_message", scope: "decidim.onboarding_action_message")
        else
          flash[:notice] = t(
            "authorizations.onboarding_pending.completed_verifications",
            scope: "decidim.verifications",
            action: onboarding_manager.action_text.downcase,
            resource_name: onboarding_manager.model_name.human.downcase
          )
        end

        redirect_to onboarding_manager.finished_redirect_path

        clear_onboarding_data!(current_user)
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

          on(:transfer_user) do |authorized_user|
            authorized_user.update(last_sign_in_at: Time.current, deleted_at: nil)
            sign_out(current_user)
            sign_in(authorized_user)

            redirect_to decidim_verifications.onboarding_pending_authorizations_path
          end

          on(:invalid) do
            flash[:alert] = t("authorizations.create.error", scope: "decidim.verifications")
            render action: :new
          end
        end
      end

      def renew_onboarding_data
        store_onboarding_cookie_data!(current_user)

        redirect_to onboarding_pending_authorizations_path
      end

      def clear_onboarding_data
        clear_onboarding_data!(current_user)
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

      def authorize_handler
        raise Decidim::ActionForbidden if current_user.ephemeral? && !Decidim::Verifications::Adapter.from_element(handler_name).ephemeral?
      end

      def set_ephemeral_user
        return if user_signed_in?

        onboarding_manager = Decidim::OnboardingManager.new(Decidim::User.new(extended_data: onboarding_cookie_data))
        authorizations = action_authorized_to(onboarding_manager.action, **onboarding_manager.action_authorized_resources)
        return unless authorizations.ephemeral?

        form = Decidim::EphemeralUserForm.new(organization: current_organization, locale: current_locale)
        CreateEphemeralUser.call(form) do
          on(:ok) do |ephemeral_user|
            sign_in(ephemeral_user)
          end
        end
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

# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module EphemeralSessionChecker
    extend ActiveSupport::Concern

    included do
      before_action :check_ephemeral_user_session, if: :ephemeral_user_signed_in?

      helper_method :onboarding_manager
    end

    private

    def ephemeral_user_signed_in?
      user_signed_in? && current_user.ephemeral?
    end

    def onboarding_manager
      @onboarding_manager ||= Decidim::OnboardingManager.new(current_user)
    end

    def check_ephemeral_user_session
      return true unless request.format.html?

      return destroy_ephemeral_session && redirect_to(decidim.root_path) if onboarding_manager.expired?

      if onboarding_manager.valid?
        authorizations = action_authorized_to(onboarding_manager.action, **onboarding_manager.action_authorized_resources)

        return redirect_to pending_authorizations_path unless authorizations_permitted_paths?(authorizations, onboarding_manager)

        if authorizations.global_code == :unauthorized
          flash[:alert] = t("unauthorized", scope: "decidim.core.actions")
          return destroy_ephemeral_session && redirect_to(decidim.root_path)
        end
      end

      return true
    end

    def destroy_ephemeral_session
      Decidim::DestroyEphemeralUser.call(current_user) do
        on(:ok) do
          sign_out(current_user)
          flash[:notice] = t("ephemeral_session_closed", scope: "decidim.devise.sessions.user")
        end

        on(:invalid) do
          flash[:alert] = t("account.destroy.error", scope: "decidim")
        end
      end
    end

    # This method determines which paths are allowed to the user based on the
    # onboarding manager data and the associated authorizations. In all cases
    # the user is allowed to visit the onboarding pending and the terms of
    # service pages. In addition:
    # * If the user is pending to complete an authorization is also allowed to
    #   navigate in the pages to complete the authorizations and the
    #   authorizations path to send the request.
    # * If the user is authorized is also allowed to visit the paths determined
    #   by the onboarding manager after finishing the authorization flow and
    #   the associated component.
    # The method checks the request path and checks if the path starts with one
    # of the paths of the allowlist
    def authorizations_permitted_paths?(authorizations, onboarding_manager)
      paths_list = if authorizations.user_pending?
                     authorizations.statuses.map(&:current_path).compact.prepend(
                       decidim_verifications.authorizations_path
                     )
                   elsif authorizations.ok?
                     [onboarding_manager.finished_redirect_path, onboarding_manager.component_path].compact
                   else
                     []
                   end
      paths_list.prepend(
        pending_authorizations_path,
        decidim.page_path(terms_of_service_page, locale: current_locale)
      )

      paths_list.find { |el| /\A#{URI.parse(el).path}/.match?(request.path) }
    end

    def pending_authorizations_path
      onboarding_manager.authorization_path || decidim_verifications.onboarding_pending_authorizations_path
    end
  end
end

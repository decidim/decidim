# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module EphemeralSessionChecker
    extend ActiveSupport::Concern

    included do
      before_action :check_ephemeral_user_session, if: :ephemeral_user_signed_in?
    end

    private

    def ephemeral_user_signed_in?
      user_signed_in? && current_user.ephemeral?
    end

    def check_ephemeral_user_session
      return true unless request.format.html?

      onboarding_manager = Decidim::OnboardingManager.new(current_user)

      return destroy_ephemeral_session && redirect_to(decidim.root_path) if onboarding_manager.expired?

      if onboarding_manager.valid?
        authorizations = action_authorized_to(onboarding_manager.action, **onboarding_manager.action_authorized_resources)

        return redirect_to decidim_verifications.onboarding_pending_authorizations_path unless authorizations_permitted_paths?(authorizations, onboarding_manager)
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
        decidim_verifications.onboarding_pending_authorizations_path,
        decidim.page_path(terms_of_service_page)
      )

      paths_list.find { |el| /\A#{URI.parse(el).path}/.match?(request.path) }
    end
  end
end

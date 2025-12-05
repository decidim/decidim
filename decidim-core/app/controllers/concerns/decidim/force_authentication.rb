# frozen_string_literal: true

module Decidim
  # Shared behaviour for force_users_to_authenticate_before_access_organization
  module ForceAuthentication
    extend ActiveSupport::Concern

    included do
      before_action :ensure_authenticated!, unless: :allow_unauthorized_path?
    end

    private

    # For Devise helper functions, see:
    # https://github.com/plataformatec/devise#getting-started
    #
    # Breaks the request lifecycle, if user is not authenticated.
    # Otherwise returns.
    def ensure_authenticated!
      return true unless current_organization&.force_users_to_authenticate_before_access_organization

      # Next stop: Check whether auth is ok
      unless user_signed_in?
        flash[:warning] = t("actions.login_before_access", scope: "decidim.core")
        redirect_to decidim.new_user_session_path
      end
    end

    # Check for all paths that should be allowed even if the user is not yet
    # authorized
    def allow_unauthorized_path?
      return true if unauthorized_paths.any? { |path| /^#{path}/.match?(request.path) }

      false
    end

    def unauthorized_paths
      default_unauthorized_paths + Decidim::StaticPage.where(
        organization: current_organization,
        allow_public_access: true
      ).pluck(
        Arel::Nodes::Concat.new(
          Arel::Nodes.build_quoted("/#{current_locale}/pages/"),
          Arel::Table.new(Decidim::StaticPage.table_name)[:slug]
        )
      )
    end

    def default_unauthorized_paths
      # /locale is for changing the locale and /manifest.webmanifest to request PWA manifest
      %w(/locale /manifest.webmanifest)
    end

    def current_locale
      @current_locale ||= I18n.locale.to_s
    end
  end
end

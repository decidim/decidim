# frozen_string_literal: true

module Decidim
  # The main application controller that inherits from Rails.
  class ApplicationController < ::DecidimController
    include Browser::ActionController

    include NeedsOrganization
    include LocaleSwitcher
    include UseOrganizationTimeZone
    include NeedsPermission
    include PayloadInfo
    include ImpersonateUsers
    include HasStoredPath
    include NeedsTosAccepted
    include HttpCachingDisabler
    include ActionAuthorization
    include ForceAuthentication
    include SafeRedirect
    include NeedsSnippets
    include UserBlockedChecker
    include DisableRedirectionToExternalHost
    include NeedsPasswordChange

    helper Decidim::MetaTagsHelper
    helper Decidim::DecidimFormHelper
    helper Decidim::LanguageChooserHelper
    helper Decidim::ReplaceButtonsHelper
    helper Decidim::TranslationsHelper
    helper Decidim::AriaSelectedLinkToHelper
    helper Decidim::MenuHelper
    helper Decidim::ComponentPathHelper
    helper Decidim::ViewHooksHelper
    helper Decidim::CardHelper
    helper Decidim::SanitizeHelper
    helper Decidim::TwitterSearchHelper
    helper Decidim::SocialShareButtonHelper

    register_permissions(::Decidim::ApplicationController,
                         ::Decidim::Admin::Permissions,
                         ::Decidim::Permissions)

    before_action :store_machine_translations_toggle
    helper_method :machine_translations_toggled?

    protect_from_forgery with: :exception, prepend: true
    after_action :add_vary_header

    layout "layouts/decidim/application"

    skip_before_action :disable_http_caching, unless: :user_signed_in?

    private

    # This overrides Devise's method for extracting the path from the URL. We
    # want to ensure the path to be stored in the cookie is not too long in
    # order to avoid ActionDispatch::Cookies::CookieOverflow exception. If the
    # session cookie (containing all the session data) is over 4 KB in length,
    # it would lead to an exception if the cookie store is being used. This is
    # a hard constraint set by ActionDispatch because some browsers do not allow
    # cookies over 4 KB.
    #
    # Original code in Devise: https://git.io/Jt6wt
    def extract_path_from_location(location)
      path = super
      return path unless Rails.application.config.session_store == ActionDispatch::Session::CookieStore

      # Allow 3 KB size for the path because there can be also some other
      # session variables out there.
      return path if path.bytesize <= ActionDispatch::Cookies::MAX_COOKIE_SIZE - 1024

      # For too long paths, remove the URL parameters
      path.split("?").first
    end

    # We store whether the user is requesting to toggle the translations or not.
    # We need to store it this way because if we use an instance variable, then
    # we're not able to access that value from inside the presenters, and we
    # need it there to translate some attributes.
    def store_machine_translations_toggle
      RequestStore.store[:toggle_machine_translations] = params[:toggle_translations].present?
    end

    def machine_translations_toggled?
      RequestStore.store[:toggle_machine_translations]
    end

    def user_has_no_permission_path
      return decidim.new_user_session_path unless user_signed_in?

      decidim.root_path
    end

    def permission_class_chain
      ::Decidim.permissions_registry.chain_for(::Decidim::ApplicationController)
    end

    def permission_scope
      :public
    end

    # Make sure Chrome doesn't use the cache from a different format. This
    # prevents a bug where clicking the back button of the browser
    # displays the JS response instead of the HTML one.
    def add_vary_header
      response.headers["Vary"] = "Accept"
    end
  end
end

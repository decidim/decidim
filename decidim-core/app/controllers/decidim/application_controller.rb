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
    include NeedsTosAccepted
    include HttpCachingDisabler
    include ActionAuthorization
    include ForceAuthentication
    include SafeRedirect

    helper Decidim::MetaTagsHelper
    helper Decidim::DecidimFormHelper
    helper Decidim::LanguageChooserHelper
    helper Decidim::ReplaceButtonsHelper
    helper Decidim::TranslationsHelper
    helper Decidim::CookiesHelper
    helper Decidim::AriaSelectedLinkToHelper
    helper Decidim::MenuHelper
    helper Decidim::ComponentPathHelper
    helper Decidim::ViewHooksHelper
    helper Decidim::CardHelper
    helper Decidim::SanitizeHelper

    register_permissions(::Decidim::ApplicationController,
                         ::Decidim::Admin::Permissions,
                         ::Decidim::Permissions)

    # Saves the location before loading each page so we can return to the
    # right page.
    before_action :store_current_location

    before_action :store_machine_translations_toggle
    helper_method :machine_translations_toggled?

    protect_from_forgery with: :exception, prepend: true
    after_action :add_vary_header

    layout "layouts/decidim/application"

    skip_before_action :disable_http_caching, unless: :user_signed_in?

    private

    # Stores the url where the user will be redirected after login.
    #
    # Uses the `redirect_url` param or the current url if there's no param.
    # In Devise controllers we only store the URL if it's from the params, we don't
    # want to overwrite the stored URL for a Devise one.
    def store_current_location
      return if skip_store_location?

      value = redirect_url || request.url
      store_location_for(:user, value)
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

    def skip_store_location?
      # Skip if Devise already handles the redirection
      return true if devise_controller? && redirect_url.blank?
      # Skip for all non-HTML requests"
      return true unless request.format.html?
      # Skip if a signed in user requests the TOS page without having agreed to
      # the TOS. Most of the times this is because of a redirect to the TOS
      # page (in which case the desired location is somewhere else after the
      # TOS is agreed).
      return true if current_user && !current_user.tos_accepted? && request.path == tos_path

      false
    end

    def user_has_no_permission_path
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

# frozen_string_literal: true

module Decidim
  # The main application controller that inherits from Rails.
  class ApplicationController < ::DecidimController
    include NeedsOrganization
    include LocaleSwitcher
    include NeedsPermission
    include PayloadInfo
    include ImpersonateUsers
    include NeedsTosAccepted
    include HttpCachingDisabler
    include ActionAuthorization

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

    # Saves the location before loading each page so we can return to the
    # right page.
    before_action :store_current_location

    protect_from_forgery with: :exception, prepend: true
    after_action :add_vary_header

    layout "layouts/decidim/application"

    skip_before_action :disable_http_caching, unless: :user_signed_in?

    before_action :track_continuity_badge

    private

    # Stores the url where the user will be redirected after login.
    #
    # Uses the `redirect_url` param or the current url if there's no param.
    # In Devise controllers we only store the URL if it's from the params, we don't
    # want to overwrite the stored URL for a Devise one.
    def store_current_location
      return if (devise_controller? && params[:redirect_url].blank?) || !request.format.html?

      value = params[:redirect_url] || request.url
      store_location_for(:user, value)
    end

    def user_has_no_permission_path
      decidim.root_path
    end

    def permission_class_chain
      [
        Decidim::Admin::Permissions,
        Decidim::Permissions
      ]
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

    def track_continuity_badge
      return unless current_user
      ContinuityBadgeTracker.new(current_user).track!(Time.zone.today)
    end
  end
end

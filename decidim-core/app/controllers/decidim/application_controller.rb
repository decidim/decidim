# frozen_string_literal: true

module Decidim
  # The main application controller that inherits from Rails.
  class ApplicationController < ::DecidimController
    include NeedsOrganization
    include LocaleSwitcher
    include NeedsAuthorization
    include PayloadInfo

    helper Decidim::MetaTagsHelper
    helper Decidim::DecidimFormHelper
    helper Decidim::LanguageChooserHelper
    helper Decidim::ReplaceButtonsHelper
    helper Decidim::TranslationsHelper
    helper Decidim::CookiesHelper
    helper Decidim::AriaSelectedLinkToHelper
    helper Decidim::MenuHelper
    helper Decidim::FeaturePathHelper

    # Saves the location before loading each page so we can return to the
    # right page. If we're on a devise page, we don't want to store that as the
    # place to return to (for example, we don't want to return to the sign in page
    # after signing in), which is what the :unless prevents
    before_action :store_current_location, unless: :devise_controller?

    protect_from_forgery with: :exception, prepend: true
    after_action :add_vary_header

    layout "layouts/decidim/application"

    alias real_user current_user

    # TODO
    def current_user
      managed_user || real_user
    end

    private

    def store_current_location
      store_location_for(:user, request.url)
    end

    def user_not_authorized_path
      decidim.root_path
    end

    # Make sure Chrome doesn't use the cache from a different format. This
    # prevents a bug where clicking the back button of the browser
    # displays the JS response instead of the HTML one.
    def add_vary_header
      response.headers["Vary"] = "Accept"
    end

    # TODO
    def managed_user
      return unless real_user.can? :impersonate, :managed_users

      impersonation = Decidim::Admin::ImpersonationLog
                      .order(:start_at)
                      .where(admin: real_user)
                      .last

      return if impersonation.expired?
      impersonation.user
    end
  end
end

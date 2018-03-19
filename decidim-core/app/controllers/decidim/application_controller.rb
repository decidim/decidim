# frozen_string_literal: true

module Decidim
  # The main application controller that inherits from Rails.
  class ApplicationController < ::DecidimController
    include NeedsOrganization
    include LocaleSwitcher
    include NeedsAuthorization
    include PayloadInfo
    include ImpersonateUsers

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

    # Saves the location before loading each page so we can return to the
    # right page.
    before_action :store_current_location

    protect_from_forgery with: :exception, prepend: true
    after_action :add_vary_header

    layout "layouts/decidim/application"

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

    def user_not_authorized_path
      decidim.root_path
    end

    # Make sure Chrome doesn't use the cache from a different format. This
    # prevents a bug where clicking the back button of the browser
    # displays the JS response instead of the HTML one.
    def add_vary_header
      response.headers["Vary"] = "Accept"
    end

    # Overwrites `cancancan`'s method to point to the correct ability class,
    # since the gem expects the ability class to be in the root namespace.
    def current_ability_klass
      Decidim::Abilities::BaseAbility
    end
  end
end

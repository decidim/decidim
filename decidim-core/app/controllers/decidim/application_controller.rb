# frozen_string_literal: true
module Decidim
  # The main application controller that inherits from Rails.
  class ApplicationController < ActionController::Base
    include Decidim::NeedsOrganization
    include Decidim::LocaleSwitcher
    include NeedsAuthorization

    helper Decidim::MetaTagsHelper
    helper Decidim::DecidimFormHelper
    helper Decidim::LanguageChooserHelper
    helper Decidim::ReplaceButtonsHelper

    # Saves the location before loading each page so we can return to the
    # right page. If we're on a devise page, we don't want to store that as the
    # place to return to (for example, we don't want to return to the sign in page
    # after signing in), which is what the :unless prevents
    before_filter :store_current_location, unless: :devise_controller?

    protect_from_forgery with: :exception, prepend: true
    after_action :add_vary_header

    layout "layouts/decidim/application"

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
  end
end

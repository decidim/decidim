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
    helper Decidim::FeaturePathHelper
    helper Decidim::ViewHooksHelper

    protect_from_forgery with: :exception, prepend: true
    after_action :add_vary_header

    layout "layouts/decidim/application"

    private

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

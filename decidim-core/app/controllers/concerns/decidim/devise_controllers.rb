# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern groups methods and helpers needed by Devise controllers.
  module DeviseControllers
    extend ActiveSupport::Concern

    included do
      include Decidim::NeedsOrganization
      include Decidim::LocaleSwitcher

      include NeedsAuthorization
      skip_authorization_check

      helper Decidim::TranslationsHelper
      helper Decidim::MetaTagsHelper
      helper Decidim::DecidimFormHelper
      helper Decidim::LanguageChooserHelper
      helper Decidim::CookiesHelper
      helper Decidim::ReplaceButtonsHelper
      helper Decidim::LayoutHelper
      helper Decidim::MenuHelper
      helper Decidim::OmniauthHelper

      layout "layouts/decidim/application"
    end

    # Overwrites `cancancan`'s method to point to the correct ability class,
    # since the gem expects the ability class to be in the root namespace.
    def current_ability_klass
      Decidim::Abilities::BaseAbility
    end
  end
end

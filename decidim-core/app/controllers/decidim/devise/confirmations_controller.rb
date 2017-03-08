# frozen_string_literal: true
module Decidim
  module Devise
    # Custom Devise ConfirmationsController to avoid namespace problems.
    class ConfirmationsController < ::Devise::ConfirmationsController
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

      layout "layouts/decidim/application"
    end
  end
end

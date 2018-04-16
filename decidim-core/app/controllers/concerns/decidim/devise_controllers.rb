# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern groups methods and helpers needed by Devise controllers.
  module DeviseControllers
    extend ActiveSupport::Concern

    included do
      include Decidim::NeedsOrganization
      include Decidim::LocaleSwitcher

      include NeedsPermission

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

      # Saves the location before loading each page so we can return to the
      # right page.
      before_action :store_current_location
    end

    def permission_class_chain
      [Decidim::Permissions]
    end

    def permission_scope
      :public
    end

    def store_current_location
      return if params[:redirect_url].blank? || !request.format.html?

      store_location_for(:user, params[:redirect_url])
    end
  end
end

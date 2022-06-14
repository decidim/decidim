# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern groups methods and helpers needed by Devise controllers.
  module DeviseControllers
    extend ActiveSupport::Concern

    RegistersPermissions
      .register_permissions(::Decidim::DeviseControllers,
                            ::Decidim::Admin::Permissions,
                            ::Decidim::Permissions)

    included do
      include Decidim::NeedsOrganization
      include Decidim::LocaleSwitcher
      include ImpersonateUsers
      include NeedsPermission
      include Decidim::SafeRedirect
      include NeedsSnippets
      include UserBlockedChecker

      helper Decidim::TranslationsHelper
      helper Decidim::MetaTagsHelper
      helper Decidim::DecidimFormHelper
      helper Decidim::LanguageChooserHelper
      helper Decidim::ReplaceButtonsHelper
      helper Decidim::LayoutHelper
      helper Decidim::MenuHelper
      helper Decidim::OmniauthHelper
      helper Decidim::CacheHelper

      layout "layouts/decidim/application"

      # Saves the location before loading each page so we can return to the
      # right page.
      before_action :store_current_location

      def permission_class_chain
        PermissionsRegistry.chain_for(DeviseControllers)
      end

      def permission_scope
        :public
      end

      def store_current_location
        return if redirect_url.blank? || !request.format.html?

        store_location_for(:user, redirect_url)
      end
    end
  end
end

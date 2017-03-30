# frozen_string_literal: true
module Decidim
  module Admin
    # The main application controller that inherits from Rails.
    class ApplicationController < ::DecidimController
      include NeedsOrganization
      include NeedsAuthorization
      include FormFactory
      include LocaleSwitcher
      include PayloadInfo
      helper Decidim::Admin::ApplicationHelper
      helper Decidim::Admin::AttributesDisplayHelper
      helper Decidim::Admin::FeatureSettingsHelper
      helper Decidim::Admin::ProcessGroupsForSelectHelper
      helper Decidim::Admin::ProcessesForSelectHelper
      helper Decidim::Admin::IconLinkHelper
      helper Decidim::DecidimFormHelper
      helper Decidim::ReplaceButtonsHelper
      helper Decidim::OrganizationScopesHelper
      helper Decidim::TranslationsHelper

      helper Decidim::LanguageChooserHelper

      protect_from_forgery with: :exception, prepend: true

      def user_not_authorized_path
        decidim_admin.root_path
      end

      # Overwrites `cancancan`'s method to point to the correct ability class,
      # since the gem expects the ability class to be in the root namespace.
      def current_ability_klass
        Decidim::Admin::Abilities::Base
      end
    end
  end
end

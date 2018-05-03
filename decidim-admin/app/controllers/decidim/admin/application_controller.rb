# frozen_string_literal: true

module Decidim
  module Admin
    # The main application controller that inherits from Rails.
    class ApplicationController < ::DecidimController
      include NeedsOrganization
      include NeedsPermission
      include FormFactory
      include LocaleSwitcher
      include PayloadInfo

      helper Decidim::Admin::ApplicationHelper
      helper Decidim::Admin::AttributesDisplayHelper
      helper Decidim::Admin::SettingsHelper
      helper Decidim::Admin::IconLinkHelper
      helper Decidim::Admin::MenuHelper
      helper Decidim::Admin::ScopesHelper
      helper Decidim::DecidimFormHelper
      helper Decidim::ReplaceButtonsHelper
      helper Decidim::ScopesHelper
      helper Decidim::TranslationsHelper
      helper Decidim::LanguageChooserHelper
      helper Decidim::ComponentPathHelper

      protect_from_forgery with: :exception, prepend: true

      def user_has_no_permission_path
        decidim_admin.root_path
      end

      def user_not_authorized_path
        decidim_admin.root_path
      end

      def permission_class_chain
        [Decidim::Admin::Permissions]
      end

      def permission_scope
        :admin
      end
    end
  end
end

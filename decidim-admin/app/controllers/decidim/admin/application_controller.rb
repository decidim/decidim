# frozen_string_literal: true

module Decidim
  module Admin
    # The main application controller that inherits from Rails.
    class ApplicationController < ::DecidimController
      include NeedsOrganization
      include NeedsPermission
      include NeedsPasswordChange
      include NeedsSnippets
      include NeedsAdminTosAccepted
      include NeedsRtlDirection
      include FormFactory
      include LocaleSwitcher
      include UseOrganizationTimeZone
      include PayloadInfo
      include Headers::HttpCachingDisabler
      include Headers::ContentSecurityPolicy
      include DisableRedirectionToExternalHost
      include Decidim::Admin::Concerns::HasBreadcrumbItems
      include ActiveStorage::SetCurrent

      helper Decidim::Admin::ApplicationHelper
      helper Decidim::Admin::AttributesDisplayHelper
      helper Decidim::Admin::SettingsHelper
      helper Decidim::Admin::IconLinkHelper
      helper Decidim::Admin::IconWithTooltipHelper
      helper Decidim::Admin::MenuHelper
      helper Decidim::Admin::ScopesHelper
      helper Decidim::DecidimFormHelper
      helper Decidim::ReplaceButtonsHelper
      helper Decidim::ScopesHelper
      helper Decidim::TaxonomiesHelper
      helper Decidim::TranslationsHelper
      helper Decidim::LanguageChooserHelper
      helper Decidim::ComponentPathHelper
      helper Decidim::SanitizeHelper
      helper Decidim::BreadcrumbHelper

      helper Decidim::Templates::Admin::ApplicationHelper if Decidim.module_installed?(:templates) && defined?(Decidim::Templates::Admin::ApplicationHelper)

      before_action :set_deleted_warning, if: :trashed_item?, only: [:edit, :show]

      default_form_builder Decidim::Admin::FormBuilder

      protect_from_forgery with: :exception, prepend: true

      register_permissions(::Decidim::Admin::ApplicationController,
                           ::Decidim::Admin::Permissions)

      def user_has_no_permission_path
        decidim_admin.root_path
      end

      def user_not_authorized_path
        decidim_admin.root_path
      end

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::Admin::ApplicationController)
      end

      def permission_scope
        :admin
      end

      def current_manifest
        [Decidim.find_resource_manifest(controller_name),
         Decidim.find_participatory_space_manifest(controller_name),
         Decidim.find_component_manifest(controller_name)].compact.first
      end

      def current_resource
        return unless current_manifest

        resource_class = current_manifest.model_class
        params[:slug] ? resource_class.find_by(slug: params[:slug]) : resource_class.find(params[:id])
      end

      def trashed_item?
        current_resource&.trashed?
      end

      def set_deleted_warning
        flash.now[:warning] = t("decidim.admin.manage_trash.deleted_items_warning")
      end
    end
  end
end

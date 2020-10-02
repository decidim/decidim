# frozen_string_literal: true

require "rails"
require "active_support/all"

require "pg"
require "redis"

require "devise"
require "devise-i18n"
require "devise_invitable"
require "jquery-rails"
require "sassc-rails"
require "foundation-rails"
require "foundation_rails_helper"
require "autoprefixer-rails"
require "active_link_to"
require "rectify"
require "carrierwave"
require "rails-i18n"
require "date_validator"
require "sprockets/es6"
require "truncato"
require "file_validators"
require "omniauth"
require "omniauth-facebook"
require "omniauth-twitter"
require "omniauth-google-oauth2"
require "invisible_captcha"
require "premailer/rails"
require "geocoder"
require "paper_trail"
require "cells/rails"
require "cells-erb"
require "kaminari"
require "doorkeeper"
require "doorkeeper-i18n"
require "nobspw"
require "kaminari"
require "batch-loader"
require "etherpad-lite"
require "diffy"
require "anchored"

require "decidim/api"

module Decidim
  module Core
    # Decidim's core Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim
      engine_name "decidim"

      initializer "decidim.action_controller" do |_app|
        ActiveSupport.on_load :action_controller do
          helper Decidim::LayoutHelper if respond_to?(:helper)
        end
      end

      initializer "decidim.middleware" do |app|
        app.config.middleware.insert_before Warden::Manager, Decidim::CurrentOrganization
        app.config.middleware.insert_before Warden::Manager, Decidim::StripXForwardedHost
        app.config.middleware.use BatchLoader::Middleware
      end

      initializer "decidim.assets" do |app|
        app.config.assets.paths << File.expand_path("../../../app/assets/stylesheets", __dir__)
        app.config.assets.precompile += %w(decidim_core_manifest.js
                                           decidim/identity_selector_dialog)

        Decidim.component_manifests.each do |component|
          app.config.assets.precompile += [component.icon]
        end

        app.config.assets.debug = true if Rails.env.test?
      end

      initializer "decidim.default_form_builder" do |_app|
        ActionView::Base.default_form_builder = Decidim::FormBuilder
      end

      initializer "decidim.exceptions_app" do |app|
        app.config.exceptions_app = Decidim::Core::Engine.routes
      end

      initializer "decidim.locales" do |app|
        app.config.i18n.fallbacks = true
      end

      initializer "decidim.graphql_api" do
        Decidim::Api::QueryType.define do
          Decidim::QueryExtensions.define(self)
        end

        Decidim::Api.add_orphan_type Decidim::Core::UserType
        Decidim::Api.add_orphan_type Decidim::Core::UserGroupType
      end

      initializer "decidim.i18n_exceptions" do
        ActionView::Base.raise_on_missing_translations = true unless Rails.env.production?
      end

      initializer "decidim.geocoding", after: :load_config_initializers do
        Geocoder.configure(Decidim.geocoder) if Decidim.geocoder.present?
      end

      initializer "decidim.geocoding_extensions", after: "geocoder.insert_into_active_record" do
        # Include it in ActiveRecord base in order to apply it to all models
        # that may be using the `geocoded_by` or `reverse_geocoded_by` class
        # methods injected by the Geocoder gem.
        ActiveSupport.on_load :active_record do
          ActiveRecord::Base.send(:include, Decidim::Geocodable)
        end
      end

      initializer "decidim.maps" do
        Decidim::Map.register_category(:dynamic, Decidim::Map::Provider::DynamicMap)
        Decidim::Map.register_category(:static, Decidim::Map::Provider::StaticMap)
        Decidim::Map.register_category(:geocoding, Decidim::Map::Provider::Geocoding)
        Decidim::Map.register_category(:autocomplete, Decidim::Map::Provider::Autocomplete)
      end

      # This keeps backwards compatibility with the old style of map
      # configuration through Decidim.geocoder.
      initializer "decidim.maps_legacysupport", after: :load_config_initializers do
        next if Decidim.maps.present?
        next if Decidim.geocoder.blank?

        legacy_api_key ||= begin
          if Decidim.geocoder[:here_api_key].present?
            Decidim.geocoder.fetch(:here_api_key)
          elsif Decidim.geocoder[:here_app_id].present?
            [
              Decidim.geocoder.fetch(:here_app_id),
              Decidim.geocoder.fetch(:here_app_code)
            ]
          end
        end
        next unless legacy_api_key

        ActiveSupport::Deprecation.warn(
          <<~DEPRECATION.strip
            Configuring maps functionality has changed.

            Please update your current Decidim.geocoder configurations to the following format:

              Decidim.configure do |config|
                config.maps = {
                  provider: :here,
                  api_key: Rails.application.secrets.maps[:api_key],
                  static: { url: "#{Decidim.geocoder.fetch(:static_map_url)}" }
                }
              end
          DEPRECATION
        )
        Decidim.configure do |config|
          config.maps = {
            provider: :here,
            api_key: legacy_api_key,
            static: {
              url: Decidim.geocoder.fetch(:static_map_url)
            }
          }
        end
      end

      initializer "decidim.stats" do
        Decidim.stats.register :users_count, priority: StatsRegistry::HIGH_PRIORITY do |organization, start_at, end_at|
          StatsUsersCount.for(organization, start_at, end_at)
        end

        Decidim.stats.register :processes_count, priority: StatsRegistry::HIGH_PRIORITY do |organization, start_at, end_at|
          processes = ParticipatoryProcesses::OrganizationPrioritizedParticipatoryProcesses.new(organization)
          processes = processes.where("created_at >= ?", start_at) if start_at.present?
          processes = processes.where("created_at <= ?", end_at) if end_at.present?
          processes.count
        end
      end

      initializer "decidim.menu" do
        Decidim.menu :menu do |menu|
          menu.item I18n.t("menu.home", scope: "decidim"),
                    decidim.root_path,
                    position: 1,
                    active: :exclusive

          menu.item I18n.t("menu.help", scope: "decidim"),
                    decidim.pages_path,
                    position: 7,
                    active: :inclusive
        end
      end

      initializer "decidim.user_menu" do
        Decidim.menu :user_menu do |menu|
          menu.item t("account", scope: "layouts.decidim.user_profile"),
                    decidim.account_path,
                    position: 1.0,
                    active: :exact

          menu.item t("notifications_settings", scope: "layouts.decidim.user_profile"),
                    decidim.notifications_settings_path,
                    position: 1.1

          if available_verification_workflows.any?
            menu.item t("authorizations", scope: "layouts.decidim.user_profile"),
                      decidim_verifications.authorizations_path,
                      position: 1.2
          end

          if current_organization.user_groups_enabled? && user_groups.any?
            menu.item t("user_groups", scope: "layouts.decidim.user_profile"),
                      decidim.own_user_groups_path,
                      position: 1.3
          end

          menu.item t("my_interests", scope: "layouts.decidim.user_profile"),
                    decidim.user_interests_path,
                    position: 1.4

          menu.item t("my_data", scope: "layouts.decidim.user_profile"),
                    decidim.data_portability_path,
                    position: 1.5

          menu.item t("delete_my_account", scope: "layouts.decidim.user_profile"),
                    decidim.delete_account_path,
                    position: 999,
                    active: :exact
        end
      end

      initializer "decidim.notifications" do
        Decidim::EventsManager.subscribe(/^decidim\.events\./) do |event_name, data|
          EventPublisherJob.perform_later(event_name, data)
        end
      end

      initializer "decidim.content_processors" do |_app|
        Decidim.configure do |config|
          config.content_processors += [:user, :user_group, :hashtag, :link]
        end
      end

      initializer "add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Core::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Core::Engine.root}/app/cells/amendable")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Core::Engine.root}/app/views") # for partials
      end

      initializer "doorkeeper" do
        Doorkeeper.configure do
          orm :active_record

          # This block will be called to check whether the resource owner is authenticated or not.
          resource_owner_authenticator do
            current_user || redirect_to(new_user_session_path)
          end

          # The controller Doorkeeper::ApplicationController inherits from.
          # Defaults to ActionController::Base.
          # https://github.com/doorkeeper-gem/doorkeeper#custom-base-controller
          base_controller "Decidim::ApplicationController"

          # Provide support for an owner to be assigned to each registered application (disabled by default)
          # Optional parameter confirmation: true (default false) if you want to enforce ownership of
          # a registered application
          # Note: you must also run the rails g doorkeeper:application_owner generator to provide the necessary support
          enable_application_owner confirmation: false

          # Define access token scopes for your provider
          # For more information go to
          # https://github.com/doorkeeper-gem/doorkeeper/wiki/Using-Scopes
          default_scopes :public
          optional_scopes []

          # Forces the usage of the HTTPS protocol in non-native redirect uris (enabled
          # by default in non-development environments). OAuth2 delegates security in
          # communication to the HTTPS protocol so it is wise to keep this enabled.
          #
          # Callable objects such as proc, lambda, block or any object that responds to
          # #call can be used in order to allow conditional checks (to allow non-SSL
          # redirects to localhost for example).
          #
          force_ssl_in_redirect_uri !Rails.env.development?

          # WWW-Authenticate Realm (default "Doorkeeper").
          realm "Decidim"
        end
      end

      initializer "OAuth inflections" do
        ActiveSupport::Inflector.inflections do |inflect|
          inflect.acronym "OAuth"
        end
      end

      initializer "SSL and HSTS" do
        Rails.application.configure do
          config.force_ssl = Rails.env.production? && Decidim.config.force_ssl
        end
      end

      initializer "Disable Rack::Runtime" do
        Rails.application.configure do
          config.middleware.delete Rack::Runtime
        end
      end

      initializer "Expire sessions" do
        Rails.application.config.session_store :cookie_store, expire_after: Decidim.config.expire_session_after
      end

      initializer "decidim.core.register_resources" do
        Decidim.register_resource(:user) do |resource|
          resource.model_class_name = "Decidim::User"
          resource.card = "decidim/user_profile"
          resource.searchable = true
        end

        Decidim.register_resource(:user_group) do |resource|
          resource.model_class_name = "Decidim::UserGroup"
          resource.card = "decidim/user_profile"
        end
      end

      initializer "decidim.core.register_metrics" do
        Decidim.metrics_registry.register(:users) do |metric_registry|
          metric_registry.manager_class = "Decidim::Metrics::UsersMetricManage"

          metric_registry.settings do |settings|
            settings.attribute :highlighted, type: :boolean, default: true
            settings.attribute :scopes, type: :array, default: %w(home)
            settings.attribute :weight, type: :integer, default: 1
          end
        end

        Decidim.metrics_registry.register(:participants) do |metric_registry|
          metric_registry.manager_class = "Decidim::Metrics::ParticipantsMetricManage"

          metric_registry.settings do |settings|
            settings.attribute :highlighted, type: :boolean, default: true
            settings.attribute :scopes, type: :array, default: %w(participatory_process)
            settings.attribute :weight, type: :integer, default: 1
            settings.attribute :stat_block, type: :string, default: "big"
          end
        end

        Decidim.metrics_registry.register(:followers) do |metric_registry|
          metric_registry.manager_class = "Decidim::Metrics::FollowersMetricManage"

          metric_registry.settings do |settings|
            settings.attribute :highlighted, type: :boolean, default: false
            settings.attribute :scopes, type: :array, default: %w(participatory_process)
            settings.attribute :weight, type: :integer, default: 10
            settings.attribute :stat_block, type: :string, default: "medium"
          end
        end
      end

      initializer "decidim.core.homepage_content_blocks" do
        Decidim.content_blocks.register(:homepage, :hero) do |content_block|
          content_block.cell = "decidim/content_blocks/hero"
          content_block.settings_form_cell = "decidim/content_blocks/hero_settings_form"
          content_block.public_name_key = "decidim.content_blocks.hero.name"

          content_block.images = [
            {
              name: :background_image,
              uploader: "Decidim::HomepageImageUploader"
            }
          ]

          content_block.settings do |settings|
            settings.attribute :welcome_text, type: :text, translated: true
          end

          content_block.default!
        end

        Decidim.content_blocks.register(:homepage, :sub_hero) do |content_block|
          content_block.cell = "decidim/content_blocks/sub_hero"
          content_block.public_name_key = "decidim.content_blocks.sub_hero.name"
          content_block.default!
        end

        Decidim.content_blocks.register(:homepage, :highlighted_content_banner) do |content_block|
          content_block.cell = "decidim/content_blocks/highlighted_content_banner"
          content_block.public_name_key = "decidim.content_blocks.highlighted_content_banner.name"
          content_block.default!
        end

        Decidim.content_blocks.register(:homepage, :how_to_participate) do |content_block|
          content_block.cell = "decidim/content_blocks/how_to_participate"
          content_block.public_name_key = "decidim.content_blocks.how_to_participate.name"
          content_block.default!
        end

        Decidim.content_blocks.register(:homepage, :last_activity) do |content_block|
          content_block.cell = "decidim/content_blocks/last_activity"
          content_block.public_name_key = "decidim.content_blocks.last_activity.name"
          content_block.default!
        end

        Decidim.content_blocks.register(:homepage, :stats) do |content_block|
          content_block.cell = "decidim/content_blocks/stats"
          content_block.public_name_key = "decidim.content_blocks.stats.name"
          content_block.default!
        end

        Decidim.content_blocks.register(:homepage, :metrics) do |content_block|
          content_block.cell = "decidim/content_blocks/metrics"
          content_block.public_name_key = "decidim.content_blocks.metrics.name"
        end

        Decidim.content_blocks.register(:homepage, :footer_sub_hero) do |content_block|
          content_block.cell = "decidim/content_blocks/footer_sub_hero"
          content_block.public_name_key = "decidim.content_blocks.footer_sub_hero.name"
          content_block.default!
        end

        Decidim.content_blocks.register(:homepage, :html) do |content_block|
          content_block.cell = "decidim/content_blocks/html"
          content_block.public_name_key = "decidim.content_blocks.html.name"
          content_block.settings_form_cell = "decidim/content_blocks/html_settings_form"

          content_block.settings do |settings|
            settings.attribute :html_content, type: :text, translated: true
          end
        end
      end

      initializer "decidim.core.newsletter_templates" do
        Decidim.content_blocks.register(:newsletter_template, :basic_only_text) do |content_block|
          content_block.cell = "decidim/newsletter_templates/basic_only_text"
          content_block.settings_form_cell = "decidim/newsletter_templates/basic_only_text_settings_form"
          content_block.public_name_key = "decidim.newsletter_templates.basic_only_text.name"

          content_block.settings do |settings|
            settings.attribute(
              :body,
              type: :text,
              translated: true,
              preview: -> { I18n.t("decidim.newsletter_templates.basic_only_text.body_preview") }
            )
          end

          content_block.default!
        end

        Decidim.content_blocks.register(:newsletter_template, :image_text_cta) do |content_block|
          content_block.cell = "decidim/newsletter_templates/image_text_cta"
          content_block.settings_form_cell = "decidim/newsletter_templates/image_text_cta_settings_form"
          content_block.public_name_key = "decidim.newsletter_templates.image_text_cta.name"

          content_block.images = [
            {
              name: :main_image,
              uploader: "Decidim::NewsletterTemplateImageUploader",
              preview: -> { ActionController::Base.helpers.asset_path("decidim/placeholder.jpg") }
            }
          ]

          content_block.settings do |settings|
            settings.attribute(
              :introduction,
              type: :text,
              translated: true,
              preview: -> { I18n.t("decidim.newsletter_templates.image_text_cta.introduction_preview") }
            )
            settings.attribute(
              :body,
              type: :text,
              translated: true,
              preview: -> { I18n.t("decidim.newsletter_templates.image_text_cta.body_preview") }
            )
            settings.attribute(
              :cta_text,
              type: :text,
              translated: true,
              preview: -> { I18n.t("decidim.newsletter_templates.image_text_cta.cta_text_preview") }
            )
            settings.attribute(
              :cta_url,
              type: :text,
              translated: true,
              preview: -> { "http://decidim.org" }
            )
          end

          content_block.default!
        end
      end

      initializer "decidim.core.add_badges" do
        Decidim::Gamification.register_badge(:invitations) do |badge|
          badge.levels = [1, 5, 10, 30, 50]
          badge.reset = ->(user) { Decidim::User.where(invited_by: user.id).count }
        end

        Decidim::Gamification.register_badge(:followers) do |badge|
          badge.levels = [1, 15, 30, 60, 100]
          badge.reset = ->(user) { user.followers.count }
        end
      end

      initializer "nbspw" do
        NOBSPW.configuration.use_ruby_grep = true
      end

      config.to_prepare do
        FoundationRailsHelper::FlashHelper.send(:include, Decidim::FlashHelperExtensions)
      end
    end
  end
end

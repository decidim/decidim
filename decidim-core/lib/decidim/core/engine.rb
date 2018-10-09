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

# Until https://github.com/andypike/rectify/pull/45 is attended, we're shipping
# with a patched version of rectify
require "rectify"
require "decidim/rectify_ext"

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
        app.config.middleware.use Decidim::CurrentOrganization
      end

      initializer "decidim.assets" do |app|
        app.config.assets.paths << File.expand_path("../../../app/assets/stylesheets", __dir__)
        app.config.assets.precompile += %w(decidim_core_manifest.js)

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

      initializer "decidim.geocoding" do
        if Decidim.geocoder.present?
          Geocoder.configure(
            # geocoding service (see below for supported options):
            lookup: :here,
            # IP address geocoding service (see below for supported options):
            # :ip_lookup => :maxmind,
            # to use an API key:
            api_key: [Decidim.geocoder&.fetch(:here_app_id), Decidim.geocoder&.fetch(:here_app_code)]
            # geocoding service request timeout, in seconds (default 3):
            # :timeout => 5,
            # set default units to kilometers:
            # :units => :km,
            # caching (see below for details):
            # :cache => Redis.new,
            # :cache_prefix => "..."
          )
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

          menu.item I18n.t("menu.more_information", scope: "decidim"),
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

          if user_groups.any?
            menu.item t("user_groups", scope: "layouts.decidim.user_profile"),
                      decidim.own_user_groups_path,
                      position: 1.3
          end

          menu.item t("my_data", scope: "layouts.decidim.user_profile"),
                    decidim.data_portability_path,
                    position: 1.4

          menu.item t("delete_my_account", scope: "layouts.decidim.user_profile"),
                    decidim.delete_account_path,
                    position: 999,
                    active: :exact
        end
      end

      initializer "decidim.notifications" do
        Decidim::EventsManager.subscribe(/^decidim\.events\./) do |event_name, data|
          EmailNotificationGeneratorJob.perform_later(
            event_name,
            data[:event_class],
            data[:resource],
            data[:recipient_ids],
            data[:extra]
          )
          NotificationGeneratorJob.perform_later(
            event_name,
            data[:event_class],
            data[:resource],
            data[:recipient_ids],
            data[:extra]
          )
        end
      end

      initializer "decidim.content_processors" do |_app|
        Decidim.configure do |config|
          config.content_processors += [:user, :hashtag]
        end
      end

      initializer "paper_trail" do
        PaperTrail.config.track_associations = false
      end

      initializer "add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Core::Engine.root}/app/cells")
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

          # Change the native redirect uri for client apps
          # When clients register with the following redirect uri, they won't be redirected to any server and the authorization code will be displayed within the provider
          # The value can be any string. Use nil to disable this feature. When disabled, clients must provide a valid URL
          # (Similar behaviour: https://developers.google.com/accounts/docs/OAuth2InstalledApp#choosingredirecturi)
          #
          native_redirect_uri "urn:ietf:wg:oauth:2.0:oob"

          # Forces the usage of the HTTPS protocol in non-native redirect uris (enabled
          # by default in non-development environments). OAuth2 delegates security in
          # communication to the HTTPS protocol so it is wise to keep this enabled.
          #
          # Callable objects such as proc, lambda, block or any object that responds to
          # #call can be used in order to allow conditional checks (to allow non-SSL
          # redirects to localhost for example).
          #
          # force_ssl_in_redirect_uri !Rails.env.development?
          #
          force_ssl_in_redirect_uri false

          # WWW-Authenticate Realm (default "Doorkeeper").
          realm "Decidim"
        end
      end

      initializer "OAuth inflections" do
        ActiveSupport::Inflector.inflections do |inflect|
          inflect.acronym "OAuth"
        end
      end

      initializer "decidim.core.register_resources" do
        Decidim.register_resource(:user) do |resource|
          resource.model_class_name = "Decidim::User"
          resource.card = "decidim/user_profile"
        end

        Decidim.register_resource(:user_group) do |resource|
          resource.model_class_name = "Decidim::UserGroup"
          resource.card = "decidim/user_profile"
        end
      end

      initializer "decidim.core.register_metrics" do
        Decidim.metrics_registry.register(
          :users,
          "Decidim::Metrics::UsersMetricManage",
          Decidim::MetricRegistry::HIGHLIGHTED
        )
      end

      initializer "decidim.core.content_blocks" do
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
    end
  end
end

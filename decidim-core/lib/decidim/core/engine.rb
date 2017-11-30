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
require "high_voltage"
require "rails-i18n"
require "date_validator"
require "sprockets/es6"
require "cancancan"
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

require "decidim/api"

require "decidim/query_extensions"
require "decidim/i18n_exceptions"

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
        app.config.assets.precompile += %w(decidim_core_manifest.js)

        Decidim.feature_manifests.each do |feature|
          app.config.assets.precompile += [feature.icon]
        end

        app.config.assets.debug = true if Rails.env.test?
      end

      initializer "decidim.high_voltage" do |_app|
        HighVoltage.configure do |config|
          config.routes = false
        end
      end

      initializer "decidim.default_form_builder" do |_app|
        ActionView::Base.default_form_builder = Decidim::FormBuilder
      end

      initializer "decidim.exceptions_app" do |app|
        app.config.exceptions_app = Decidim::Core::Engine.routes
      end

      initializer "decidim.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.abilities << "Decidim::Abilities::EveryoneAbility"
          config.abilities << "Decidim::Abilities::AdminAbility"
          config.abilities << "Decidim::Abilities::UserManagerAbility"
          config.abilities << "Decidim::Abilities::ParticipatoryProcessAdminAbility"
          config.abilities << "Decidim::Abilities::ParticipatoryProcessCollaboratorAbility"
          config.abilities << "Decidim::Abilities::ParticipatoryProcessModeratorAbility"
        end
      end

      initializer "decidim.locales" do |app|
        app.config.i18n.fallbacks = true
      end

      initializer "decidim.query_extensions" do
        QueryExtensions.extend!(Decidim::Api::QueryType)
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
                    position: 3,
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

      initializer "paper_trail" do
        PaperTrail.config.track_associations = false
      end
    end
  end
end

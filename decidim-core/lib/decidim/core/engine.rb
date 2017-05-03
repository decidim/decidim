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
require "nokogiri"
require "geocoder"

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

      initializer "decidim_admin.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.abilities << "Decidim::Abilities::Everyone"
        end
      end

      initializer "decidim.locales" do |app|
        app.config.i18n.available_locales = Decidim.config.available_locales
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
        Decidim.stats.register :users_count, priority: StatsRegistry::HIGH_PRIORITY do |organization|
          Decidim::User.where(organization: organization).count
        end

        Decidim.stats.register :processes_count, priority: StatsRegistry::HIGH_PRIORITY do |organization|
          (OrganizationParticipatoryProcesses.new(organization) | PublicParticipatoryProcesses.new).count
        end
      end
    end
  end
end

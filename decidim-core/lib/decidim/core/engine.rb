# frozen_string_literal: true
require "rails"
require "active_support/all"

require "pg"
require "redis"

require "devise"
require "devise-i18n"
require "devise_invitable"
require "jquery-rails"
require "sass-rails"
require "turbolinks"
require "foundation-rails"
require "foundation_rails_helper"
require "jbuilder"
require "active_link_to"
require "rectify"
require "roadie-rails"
require "carrierwave"
require "high_voltage"

module Decidim
  module Core
    # Decidim's core Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim
      engine_name "decidim"

      initializer "decidim.action_controller" do |_app|
        ActiveSupport.on_load :action_controller do
          helper Decidim::LayoutHelper
        end
      end

      initializer "decidim.middleware" do |app|
        app.config.middleware.use Decidim::CurrentOrganization
      end

      initializer "decidim.assets" do |app|
        app.config.assets.precompile += %w(decidim_core_manifest.js)
      end

      initializer "decidim.high_voltage" do |_app|
        HighVoltage.configure do |config|
          config.routes = false
        end
      end

      initializer "decidim.default_form_builder" do |_app|
        ActionView::Base.default_form_builder = Decidim::FormBuilder
      end
    end
  end
end

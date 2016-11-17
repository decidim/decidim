# frozen_string_literal: true
require "rails"
require "active_support/all"

require "devise"
require "devise-i18n"
require "decidim/core"
require "jquery-rails"
require "sass-rails"
require "turbolinks"
require "foundation-rails"
require "foundation_rails_helper"
require "jbuilder"
require "rectify"

module Decidim
  module System
    # Decidim's core Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::System

      initializer "decidim_system.mount_routes" do |_app|
        Decidim::Core::Engine.routes do
          mount Decidim::System::Engine => "/system"
        end
      end

      initializer "decidim_system.assets" do |app|
        app.config.assets.precompile += %w(decidim_system_manifest.js)
      end
    end
  end
end

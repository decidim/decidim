# frozen_string_literal: true
require "rails"
require "active_support/all"

require "devise"
require "devise-i18n"
require "decidim/core"
require "jquery-rails"
require "sassc-rails"
require "foundation-rails"
require "foundation_rails_helper"
require "rectify"

require_dependency File.join(File.dirname(__FILE__), "..", "..", "..", "app/models/decidim/admin/abilities/admin_user")

module Decidim
  module Admin
    # Decidim's core Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Admin

      initializer "decidim_admin.mount_routes" do |_app|
        Decidim::Core::Engine.routes do
          mount Decidim::Admin::Engine => "/admin"
        end
      end

      initializer "decidim_admin.assets" do |app|
        app.config.assets.precompile += %w(decidim_admin_manifest.js)
      end

      initializer "decidim_admin.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.abilities += ["Decidim::Admin::Abilities::AdminUser"]
          config.abilities += ["Decidim::Admin::Abilities::ParticipatoryProcessAdmin"]
          config.abilities += ["Decidim::Admin::Abilities::CollaboratorUser"]
        end
      end
    end
  end
end

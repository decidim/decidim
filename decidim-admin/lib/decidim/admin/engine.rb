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

require_relative "../../../app/models/decidim/admin/concerns/user_extends"

module Decidim
  module Admin
    # Decidim's core Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Admin

      initializer "decidim_admin.assets" do |app|
        app.config.assets.precompile += %w(decidim_admin_manifest.js)
      end

      initializer "decidim_admin.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.abilities += [Decidim::Admin::Abilities::AdminUser]
        end
      end

      initializer "decidim_admin.inject_concerns_to_user_model" do |app|
        app.config.to_prepare do
          Decidim::User.include Decidim::Admin::UserExtends
        end
      end
    end
  end
end

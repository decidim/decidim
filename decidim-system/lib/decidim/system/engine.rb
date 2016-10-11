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

      config.to_prepare do
        Rails.application.config.assets.precompile += %w(
          decidim/system.js
          decidim/system.css
        )
      end
    end
  end
end

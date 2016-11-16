# frozen_string_literal: true
require "rails"
require "active_support/all"

require "decidim/core"
require "jquery-rails"
require "sass-rails"
require "turbolinks"
require "foundation-rails"
require "foundation_rails_helper"

module Decidim
  module Comments
    # Decidim's core Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Comments

      initializer "decidim_comments.assets" do |app|
        app.config.assets.precompile += %w(decidim_comments_manifest.js)
      end
    end
  end
end

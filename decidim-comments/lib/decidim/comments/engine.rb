# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"
require "jquery-rails"
require "sassc-rails"
require "foundation-rails"
require "foundation_rails_helper"
require "autoprefixer-rails"

require "decidim/comments/query_extensions"
require "decidim/comments/mutation_extensions"

module Decidim
  module Comments
    # Decidim's core Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Comments

      initializer "decidim_comments.assets" do |app|
        app.config.assets.precompile += %w(decidim_comments_manifest.js)
      end

      initializer "decidim_comments.query_extensions" do
        Decidim::Api::QueryType.define do
          QueryExtensions.define(self)
        end
      end

      initializer "decidim_comments.mutation_extensions" do
        Decidim::Api::MutationType.define do
          MutationExtensions.define(self)
        end
      end

      initializer "decidim.stats" do
        Decidim.stats.register :comments_count, priority: StatsRegistry::MEDIUM_PRIORITY do |organization|
          Decidim.component_manifests.sum do |component|
            component.stats.filter(tag: :comments).with_context(organization.published_components).map { |_name, value| value }.sum
          end
        end
      end

      initializer "decidim_comments.register_metrics" do
        Decidim.metrics_registry.register(
          :comments,
          "Decidim::Comments::Metrics::CommentsMetricManage",
          Decidim::MetricRegistry::NOT_HIGHLIGHTED,
          6
        )
      end
    end
  end
end

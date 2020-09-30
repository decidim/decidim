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
        Decidim.metrics_registry.register(:comments) do |metric_registry|
          metric_registry.manager_class = "Decidim::Comments::Metrics::CommentsMetricManage"

          metric_registry.settings do |settings|
            settings.attribute :highlighted, type: :boolean, default: false
            settings.attribute :scopes, type: :array, default: %w(home participatory_process)
            settings.attribute :weight, type: :integer, default: 6
            settings.attribute :stat_block, type: :string, default: "small"
          end
        end

        Decidim.metrics_operation.register(:participants, :comments) do |metric_operation|
          metric_operation.manager_class = "Decidim::Comments::Metrics::CommentParticipantsMetricMeasure"
        end
      end

      initializer "decidim_comments.register_resources" do
        Decidim.register_resource(:comment) do |resource|
          resource.model_class_name = "Decidim::Comments::Comment"
          resource.card = "decidim/comments/comment"
          resource.searchable = true
        end
      end

      initializer "decidim_comments.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Comments::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Comments::Engine.root}/app/views") # for partials
      end
    end
  end
end

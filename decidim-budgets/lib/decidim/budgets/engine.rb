# frozen_string_literal: true

require "searchlight"
require "kaminari"

module Decidim
  module Budgets
    # This is the engine that runs on the public interface of `decidim-budgets`.
    # It mostly handles rendering the created projects associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Budgets

      routes do
        resources :budgets, only: [:index, :show] do
          resources :projects, only: [:index, :show]
          resource :order, only: [:destroy] do
            member do
              post :checkout
            end
            resource :line_item, only: [:create, :destroy]
          end
        end

        root to: "budgets#index"
      end

      initializer "decidim_budgets.assets" do |app|
        app.config.assets.precompile += %w(decidim_budgets_manifest.js)
      end

      initializer "decidim_budgets.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Budgets::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Budgets::Engine.root}/app/views") # for partials
      end

      initializer "decidim_budgets.register_metrics" do
        Decidim.metrics_operation.register(:participants, :budgets) do |metric_operation|
          metric_operation.manager_class = "Decidim::Budgets::Metrics::BudgetParticipantsMetricMeasure"
        end

        Decidim.metrics_operation.register(:followers, :budgets) do |metric_operation|
          metric_operation.manager_class = "Decidim::Budgets::Metrics::BudgetFollowersMetricMeasure"
        end
      end

      # initializer "decidim_budgets.serializer_listener" do
      #   ActiveSupport::Notifications.subscribe("decidim.budgets.projectserializer") do |_event_name, data|
      #     array = data[:serializeable].to_a
      #     # Rails.logger.info "\n\n\n\n\n\n\n\n\n\n\nARRAYIS: #{array}\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
      #     array.insert(9, [:pending_votes, data[:resource].orders.pending.count])
      #     # Rails.logger.info "\n\n\n\n\n\n\n\n\n\n\nARRAYIS2: #{array}\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
      #     # data[:klass].serializeable = array.compact.to_h
      #   end
      # end
    end
  end
end

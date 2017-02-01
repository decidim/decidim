# frozen_string_literal: true
require "searchlight"
require "kaminari"

module Decidim
  module Budgets
    # This is the engine that runs on the public interface of `decidim-budgets`.
    # It mostly handles rendering the created projects associated to a participatory
    # process.
    class ListEngine < ::Rails::Engine
      isolate_namespace Decidim::Budgets

      routes do
        resources :projects, only: [:index, :show]
        resource :order, only: [:destroy] do
          member do
            post :checkout
          end
          resource :line_item, only: [:create, :destroy]
        end

        root to: "projects#index"
      end

      initializer "decidim_budgets.assets" do |app|
        app.config.assets.precompile += %w(decidim_budgets_manifest.js)
      end
    end
  end
end

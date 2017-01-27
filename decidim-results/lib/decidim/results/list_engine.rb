# frozen_string_literal: true
require "searchlight"
require "kaminari"

module Decidim
  module Results
    # This is the engine that runs on the public interface of `decidim-results`.
    # It mostly handles rendering the created results associated to a participatory
    # process.
    class ListEngine < ::Rails::Engine
      isolate_namespace Decidim::Results

      routes do
        resources :results, only: [:index, :show]
        root to: "results#index"
      end
    end
  end
end

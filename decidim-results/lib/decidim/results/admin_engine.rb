# frozen_string_literal: true
module Decidim
  module Results
    # This is the engine that runs on the public interface of `decidim-results`.
    # It mostly handles rendering the created reuslts associated to a participatory
    # process.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Results::Admin

      paths["db/migrate"] = nil

      routes do
        resources :results
        root to: "results#index"
      end

      def load_seed
        nil
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Elections
    # This is the engine that runs on the public interface of `Elections`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Elections::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :elections do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "elections#index"
      end

      def load_seed
        nil
      end
    end
  end
end

# frozen_string_literal: true
module Decidim
  module Proposals
    # This is the engine that runs on the public interface of `decidim-proposals`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Proposals::Admin

      paths["db/migrate"] = nil

      routes do
        resources :proposals, only: [:index, :new, :create]
        root to: "proposals#index"
      end

      def load_seed
        nil
      end
    end
  end
end

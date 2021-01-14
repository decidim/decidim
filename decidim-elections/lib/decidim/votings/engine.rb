# frozen_string_literal: true

module Decidim
  module Votings
    # This is the engine that runs on the public interface for Votings of `decidim-elections`.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Votings

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # resource :votings, path: "/", only: [:index, :show, :update]
      end

      def load_seed
        nil
      end
    end
  end
end

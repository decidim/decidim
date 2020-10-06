# frozen_string_literal: true

module Decidim
  module EuRegistrations
    # This is the engine that runs on the public interface of `EuRegistrations`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::EuRegistrations::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :eu_registrations do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "eu_registrations#index"
      end

      def load_seed
        nil
      end
    end
  end
end

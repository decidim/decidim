# frozen_string_literal: true

module Decidim
  module Elections
    # This is the engine that runs on the public interface of `decidim-elections`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Elections::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :elections do
          get :manage_trash, on: :collection

          member do
            put :publish
            put :unpublish
            patch :soft_delete
            patch :restore
          end
        end
        root to: "elections#index"
      end

      def load_seed
        nil
      end
    end
  end
end

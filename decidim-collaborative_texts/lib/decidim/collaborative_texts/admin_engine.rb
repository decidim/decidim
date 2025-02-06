# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # This is the engine that runs on the public interface of `decidim-collaborative_texts`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::CollaborativeTexts::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :documents, except: [:destroy], controller: "documents" do
          resources :settings, only: [:index, :create], controller: "settings"
          member do
            patch :soft_delete
            patch :restore
            put :publish
            put :unpublish
          end

          get :manage_trash, on: :collection
        end

        root to: "documents#index"
      end

      def load_seed
        nil
      end
    end
  end
end

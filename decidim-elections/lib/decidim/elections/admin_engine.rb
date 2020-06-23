# frozen_string_literal: true

module Decidim
  module Elections
    # This is the engine that runs on the public interface of `Elections`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Elections::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :elections do
          resources :questions do
            resources :answers do
              get :proposals_picker, on: :collection
              collection do
                resource :proposals_import, only: [:new, :create]
              end
            end
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

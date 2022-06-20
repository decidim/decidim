# frozen_string_literal: true

module Decidim
  module Budgets
    # This is the engine that runs on the public interface of `decidim-budgets`.
    # It mostly handles rendering the created projects associated to a participatory
    # process.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Budgets::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :budgets do
          resources :projects do
            collection do
              post :update_category
              post :update_scope
              post :update_selected
              resource :proposals_import, only: [:new, :create]
            end
          end
        end

        resources :projects, exclude: [:index, :new, :create, :edit, :update, :destroy] do
          get :proposals_picker, on: :collection

          resources :attachment_collections
          resources :attachments
        end

        root to: "budgets#index"
      end

      def load_seed
        nil
      end
    end
  end
end

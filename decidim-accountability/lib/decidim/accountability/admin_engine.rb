# frozen_string_literal: true

module Decidim
  module Accountability
    # This is the engine that runs on the admin interface of `decidim-accountability`.
    # It mostly handles rendering the created results and projects associated to a
    # participatory process.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Accountability::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :statuses
        resources :results, except: [:show, :destroy] do
          member do
            patch :soft_delete
            patch :restore
          end

          collection do
            post :update_taxonomies, controller: "results_bulk_actions"
            post :update_status, controller: "results_bulk_actions"
            post :update_dates, controller: "results_bulk_actions"
          end

          get :proposals_picker, on: :collection
          get :manage_trash, on: :collection

          resources :attachment_collections, except: [:show]
          resources :attachments, except: [:show]
          resources :milestones, except: [:show]
        end
        resources :import_components, only: [:new, :create] do
          get :preview, on: :collection
        end
        get :import_results, to: "import_results#new"
        post :import_results, to: "import_results#create"
        root to: "results#index"
      end

      def load_seed
        nil
      end
    end
  end
end

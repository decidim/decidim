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
        resources :results, except: [:show] do
          get :proposals_picker, on: :collection

          resources :attachment_collections
          resources :attachments
          resources :timeline_entries, except: [:show]
        end
        resources :projects_import, only: [:new, :create]
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

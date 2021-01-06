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

          resources :timeline_entries, except: [:show]
        end
        get :import_results, to: "import_results#new"
        post :import_results, to: "import_results#create"
        root to: "results#index"
      end

      def load_seed
        nil
      end

      initializer "decidim_accountability.assets" do |app|
        app.config.assets.precompile += %w(decidim_accountability_admin_manifest.js)
      end

      # Initializer must go here otherwise every engine triggers config/initializers/ files
      initializer "decidim_accountability_admin.overrides" do |_app|
        Rails.application.config.to_prepare do
          Dir.glob(Decidim::Accountability::AdminEngine.root + "app/overrides/**/*.rb").each do |c|
            require_dependency(c)
          end
        end
      end
    end
  end
end

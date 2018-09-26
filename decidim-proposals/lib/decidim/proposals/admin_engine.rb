# frozen_string_literal: true

module Decidim
  module Proposals
    # This is the engine that runs on the public interface of `decidim-proposals`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Proposals::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :proposals, only: [:index, :new, :create, :edit, :update] do
          post :update_category, on: :collection
          collection do
            resource :proposals_import, only: [:new, :create]
          end
          resources :proposal_answers, only: [:edit, :update]
          resources :proposal_notes, only: [:index, :create]
        end

        root to: "proposals#index"
      end

      initializer "decidim_proposals.admin_assets" do |app|
        app.config.assets.precompile += %w(admin/decidim_proposals_manifest.js)
      end

      def load_seed
        nil
      end
    end
  end
end

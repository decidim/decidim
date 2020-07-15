# frozen_string_literal: true

module Decidim
  module Proposals
    # This is the engine that runs on the public interface of `decidim-proposals`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Proposals::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :proposals, only: [:show, :index, :new, :create, :edit, :update] do
          resources :valuation_assignments, only: [:destroy]
          collection do
            post :update_category
            post :publish_answers
            post :update_scope
            resource :proposals_import, only: [:new, :create]
            resource :proposals_merge, only: [:create]
            resource :proposals_split, only: [:create]
            resource :valuation_assignment, only: [:create, :destroy]
          end
          resources :proposal_answers, only: [:edit, :update]
          resources :proposal_notes, only: [:create]
        end

        resources :participatory_texts, only: [:index] do
          collection do
            get :new_import
            post :import
            patch :import
            post :update
            post :discard
          end
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

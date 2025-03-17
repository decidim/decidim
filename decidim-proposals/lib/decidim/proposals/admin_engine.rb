# frozen_string_literal: true

require "decidim/proposals/admin_filter"

module Decidim
  module Proposals
    # This is the engine that runs on the public interface of `decidim-proposals`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Proposals::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :proposals, only: [:show, :index, :new, :create, :edit, :update] do
          resources :evaluation_assignments, only: [:destroy]
          member do
            patch :soft_delete
            patch :restore
          end
          collection do
            post :update_taxonomies
            post :publish_answers
            post :update_multiple_answers, controller: "proposal_answers"
            get :manage_trash, controller: "proposals"
            resource :proposals_import, only: [:new, :create]
            resource :proposals_merge, only: [:new, :create]
            resource :proposals_split, only: [:create]
            resource :evaluation_assignment, only: [:create, :destroy]
          end
          resources :proposal_answers, only: [:edit, :update]
          resources :proposal_notes, only: [:create] do
            member do
              post :reply
            end
          end
        end

        resources :proposal_states

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

      initializer "decidim_proposals.admin_filters" do
        Decidim::Proposals::AdminFilter.register_filter!
      end

      def load_seed
        nil
      end
    end
  end
end

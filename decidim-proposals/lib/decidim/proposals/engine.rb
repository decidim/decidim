# frozen_string_literal: true
require "kaminari"
require "social-share-button"

module Decidim
  module Proposals
    # This is the engine that runs on the public interface of `decidim-proposals`.
    # It mostly handles rendering the created page associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Proposals

      routes do
        resources :proposals, only: [:create, :new, :index, :show] do
          resource :proposal_vote, only: [:create, :destroy]
        end
        root to: "proposals#index"
      end

      initializer "decidim_proposals.assets" do |app|
        app.config.assets.precompile += %w(decidim_proposals_manifest.js decidim_proposals_manifest.css)
      end
    end
  end
end

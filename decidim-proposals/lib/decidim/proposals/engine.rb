# frozen_string_literal: true
require "kaminari"

module Decidim
  module Proposals
    # This is the engine that runs on the public interface of `decidim-proposals`.
    # It mostly handles rendering the created page associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Proposals

      routes do
        resources :proposals, only: [:create, :new, :index, :show]
        root to: "proposals#index"
      end
    end
  end
end

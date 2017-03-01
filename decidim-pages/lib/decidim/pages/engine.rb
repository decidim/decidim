# frozen_string_literal: true
module Decidim
  module Pages
    # This is the engine that runs on the public interface of `decidim-pages`.
    # It mostly handles rendering the created page associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Pages

      routes do
        resources :pages, only: [:show], controller: :application
        root to: "application#show"
      end
    end
  end
end

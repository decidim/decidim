# frozen_string_literal: true

module Decidim
  module Elections
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Elections

      routes do
        resources :elections, only: [:index, :show]
        scope "/elections" do
          root to: "elections#index"
        end
        get "/", to: redirect("/elections", status: 301)
      end
    end
  end
end

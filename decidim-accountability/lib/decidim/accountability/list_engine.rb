# frozen_string_literal: true

require "searchlight"
require "kaminari"

module Decidim
  module Accountability
    # This is the engine that runs on the public interface of `decidim-accountability`.
    # It mostly handles rendering the created results associated to a participatory
    # process.
    class ListEngine < ::Rails::Engine
      isolate_namespace Decidim::Accountability

      routes do
        resources :results, only: [:index, :show] do
          resource :result_widget, only: :show, path: "embed"
        end
        get "csv", to: "results#csv"
        root to: "results#home"
      end

      initializer "decidim_accountability.assets" do |app|
        app.config.assets.precompile += %w(decidim_accountability_manifest.js)
      end
    end
  end
end

# frozen_string_literal: true
require "searchlight"
require "kaminari"
require "jquery-tmpl-rails"

module Decidim
  module Meetings
    # This is the engine that runs on the public interface of `decidim-meetings`.
    # It mostly handles rendering the created meeting associated to a participatory
    # process.
    class ListEngine < ::Rails::Engine
      isolate_namespace Decidim::Meetings

      routes do
        resources :meetings, only: [:index, :show] do
          member do
            get :static_map
          end
        end
        root to: "meetings#index"
      end

      initializer "decidim_meetings.assets" do |app|
        app.config.assets.precompile += %w(decidim_meetings_manifest.js)
      end
    end
  end
end

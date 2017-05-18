# frozen_string_literal: true
require "searchlight"
require "kaminari"
require "jquery-tmpl-rails"

module Decidim
  module Meetings
    # This is the engine that runs on the public interface of `decidim-meetings`.
    # It mostly handles rendering the created meeting associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Meetings

      routes do
        resources :meetings, only: [:index, :show] do
          resource :meeting_widget, only: :show, path: "embed"
        end
        root to: "meetings#index"
      end
    end
  end
end

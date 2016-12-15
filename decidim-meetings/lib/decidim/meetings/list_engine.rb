# frozen_string_literal: true
module Decidim
  module Meetings
    # This is the engine that runs on the public interface of `decidim-meetings`.
    # It mostly handles rendering the created meeting associated to a participatory
    # process.
    class ListEngine < ::Rails::Engine
      isolate_namespace Decidim::Meetings

      routes do
        resources :meetings, only: [:index, :show]
        root to: "meetings#index"
      end
    end
  end
end

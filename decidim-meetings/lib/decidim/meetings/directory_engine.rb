# frozen_string_literal: true

require "decidim/meetings/content_blocks/registry_manager"

module Decidim
  module Meetings
    # This is the engine that runs on the public interface of `decidim-meetings`.
    # It mostly handles rendering the created meeting associated to a participatory
    # process.
    class DirectoryEngine < ::Rails::Engine
      isolate_namespace Decidim::Meetings::Directory

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :meetings, only: [:index], format: :html
        get "/calendar", to: "meetings#calendar"
        root to: "meetings#index", format: :html
      end

      def load_seed
        nil
      end

      initializer "decidim_meetings_directory.content_blocks" do
        Decidim::Meetings::ContentBlocks::RegistryManager.register!
      end
    end
  end
end

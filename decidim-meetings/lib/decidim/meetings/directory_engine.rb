# frozen_string_literal: true

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
        root to: "meetings#index", format: :html
      end

      def load_seed
        nil
      end
    end
  end
end

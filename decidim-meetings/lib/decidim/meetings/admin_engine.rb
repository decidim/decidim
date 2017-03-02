# frozen_string_literal: true

module Decidim
  module Meetings
    # This is the engine that runs on the public interface of `decidim-meetings`.
    # It mostly handles rendering the created meeting associated to a participatory
    # process.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Meetings::Admin

      paths["db/migrate"] = nil

      routes do
        resources :meetings do
          resources :meeting_closes, only: [:edit, :update]
          resources :attachments
        end
        root to: "meetings#index"
      end

      def load_seed
        nil
      end
    end
  end
end

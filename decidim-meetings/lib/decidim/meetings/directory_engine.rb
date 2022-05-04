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
        get "/calendar", to: "meetings#calendar"
        root to: "meetings#index", format: :html
      end

      def load_seed
        nil
      end

      initializer "decidim.meetings.content_blocks" do
        Decidim.content_blocks.register(:homepage, :upcoming_meetings) do |content_block|
          content_block.cell = "decidim/meetings/content_blocks/upcoming_meetings"
          content_block.public_name_key = "decidim.meetings.content_blocks.upcoming_meetings.name"
          content_block.default!
        end
      end
    end
  end
end

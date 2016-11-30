# frozen_string_literal: true
module Decidim
  module Meetings
    # This is the admin interface for `decidim-meetings`. It lets you edit and
    # configure the page associated to a participatory process.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Meetings::Admin

      routes do
        post "/", to: "meetings#update", as: :meeting
        root to: "meetings#edit"
      end

      def load_seed
        nil
      end
    end
  end
end

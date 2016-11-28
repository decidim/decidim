# frozen_string_literal: true
module Decidim
  module Pages
    # This is the admin interface for `decidim-pages`. It lets you edit and
    # configure the page associated to a participatory process.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Pages::Admin

      routes do
        post "/", to: "pages#update", as: :page
        root to: "pages#edit"
      end

      def load_seed
        nil
      end
    end
  end
end

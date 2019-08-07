# frozen_string_literal: true

module Decidim
  module Blogs
    # This is the admin interface for `decidim-blogs`. It lets you edit and
    # configure the blog associated to a participatory process.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Blogs::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :posts
        root to: "posts#index"
      end

      def load_seed
        nil
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Comments
    # This is the engine that runs on the public interface of `decidim-comments`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Comments::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      resources :comments do
        collection do
          resource :permissions, controller: "comment_permissions"
        end
      end

      def load_seed
        nil
      end
    end
  end
end

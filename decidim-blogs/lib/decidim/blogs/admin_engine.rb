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
        resources :posts, except: [:destroy] do
          resources :attachment_collections, except: [:show]
          resources :attachments, except: [:show]
          get :manage_trash, on: :collection

          member do
            patch :soft_delete
            patch :restore
          end
        end
        root to: "posts#index"
      end

      def load_seed
        nil
      end
    end
  end
end

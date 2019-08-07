# frozen_string_literal: true

module Decidim
  module Budgets
    # This is the engine that runs on the public interface of `decidim-budgets`.
    # It mostly handles rendering the created projects associated to a participatory
    # process.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Budgets::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :projects do
          resources :attachment_collections
          resources :attachments
          collection do
            resource :proposals_import, only: [:new, :create]
          end
        end

        root to: "projects#index"
      end

      def load_seed
        nil
      end
    end
  end
end

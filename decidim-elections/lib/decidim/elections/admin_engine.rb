# frozen_string_literal: true

module Decidim
  module Elections
    # This is the engine that runs on the public interface of `Elections`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Elections::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :elections do
          member do
            put :publish
            put :unpublish
          end
          resources :questions do
            resources :answers do
              get :proposals_picker, on: :collection
              collection do
                resource :proposals_import, only: [:new, :create]
              end
            end
          end
        end

        resources :trustees, only: [:index, :new, :create, :destroy]
        resources :trustees_participatory_spaces, only: [:edit]

        root to: "elections#index"
      end

      def self.participatory_space_endpoints
        [:trustees]
      end

      initializer "decidim_admin_elections.view_hooks" do
        Decidim::Admin.view_hooks.register(:admin_secondary_nav, priority: Decidim::ViewHooks::MEDIUM_PRIORITY) do |view_context|
          component = view_context.current_participatory_space.components.find_by(manifest_name: :elections)
          if component
            view_context.render(
              partial: "decidim/elections/admin/shared/trustees_secondary_nav",
              locals: {
                current_component: component,
                engine_router: Decidim::EngineRouter.admin_proxy(component)
              }
            )
          end
        end
      end

      def load_seed
        nil
      end
    end
  end
end

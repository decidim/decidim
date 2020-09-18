# frozen_string_literal: true

module Decidim
  module Elections
    # This is the engine that runs on the public interface of `Elections`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Elections::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        get "/answer_options", to: "feedback_forms#answer_options", as: :answer_options_election_feedback, defaults: { format: "json" }

        resources :elections do
          member do
            put :publish
            put :unpublish
            resource :feedback_form, only: [:edit, :update]
          end
          resources :questions do
            resources :answers do
              collection do
                get :proposals_picker
                resource :proposals_import, only: [:new, :create]
              end
            end
          end
        end

        resources :trustees, only: [:index, :new, :edit, :create, :destroy], controller: "trustees_participatory_spaces"

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

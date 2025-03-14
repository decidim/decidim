# frozen_string_literal: true

require "decidim/templates/menu"

module Decidim
  module Templates
    # This is the engine that runs on the public interface of `Templates`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Templates::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        constraints(->(request) { Decidim::Admin::OrganizationDashboardConstraint.new(request).matches? }) do
          resources :proposal_answer_templates do
            member do
              post :copy
            end
            collection do
              get :fetch
            end
          end

          ## Routes for Questionnaire Templates
          resources :questionnaire_templates do
            member do
              post :copy
              get :edit_questions
              patch :update_questions
              resource :questionnaire, module: :questionnaire_templates # To manage the templatable resource
            end

            collection do
              post :apply # To use when creating an object from a template
              post :skip # To use when creating an object without a template
              get :preview # To provide a preview for the template in the object creation view
            end
          end

          resources :block_user_templates do
            member do
              post :copy
            end
            collection do
              get :fetch
            end
          end

          get "/questionnaire_template/questionnaire/response_options", to: "questionnaire_templates/questionnaires#response_options", as: "response_options_template"

          root to: "questionnaire_templates#index"
        end
      end

      initializer "decidim_templates_admin.mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::Templates::AdminEngine, at: "/admin/templates", as: "decidim_admin_templates"
        end
      end

      initializer "decidim_templates_admin.menu" do
        Decidim::Templates::Menu.register_admin_template_types_menu!
        Decidim::Templates::Menu.register_admin_menu!
      end

      def load_seed
        nil
      end
    end
  end
end

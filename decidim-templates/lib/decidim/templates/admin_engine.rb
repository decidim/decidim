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

        get "/questionnaire_template/questionnaire/answer_options", to: "questionnaires#answer_options", as: "answer_options_template"

        root to: "questionnaire_templates#index"
      end

      initializer "decidim_templates_admin.participatory_processes_menu" do
        Decidim::Templates::Menu.register_admin_template_types_menu!
      end

      initializer "decidim_templates_admin.menu" do
        Decidim::Templates::Menu.register_admin_menu!
      end

      def load_seed
        nil
      end
    end
  end
end

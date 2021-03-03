# frozen_string_literal: true

module Decidim
  module Templates
    # This is the engine that runs on the public interface of `Templates`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Templates::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
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

        get "/questionnaire_template/questionnaire/answer_options", to: "questionnaires#answer_options", as: "answer_options_template"

        root to: "questionnaire_templates#index"
      end

      initializer "decidim_templates.action_controller" do |_app|
        ActiveSupport.on_load :action_controller do
          helper Decidim::Templates::Admin::TemplatesMenuHelper if respond_to?(:helper)
        end
      end

      initializer "decidim_participatory_processes.admin_participatory_processes_menu" do
        Decidim.menu :admin_template_types_menu do |menu|
          template_types.each_pair do |name, url|
            menu.item name, url,
                      if: allowed_to?(:index, :templates),
                      active: is_active_link?(url)
          end
        end
      end

      initializer "decidim_templates.admin_mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::Templates::AdminEngine, at: "/admin/templates", as: "decidim_admin_templates"
        end
      end

      initializer "decidim_templates.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.templates", scope: "decidim.admin", default: "Templates"),
                    decidim_admin_templates.questionnaire_templates_path,
                    icon_name: "document",
                    position: 12,
                    active: :inclusive
        end
      end

      def load_seed
        nil
      end
    end
  end
end

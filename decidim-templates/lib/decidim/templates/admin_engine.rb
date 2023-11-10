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
        Decidim.menu :admin_template_types_menu do |menu|
          menu.add_item :questionnaires,
                        I18n.t("template_types.questionnaires", scope: "decidim.templates"),
                        decidim_admin_templates.questionnaire_templates_path,
                        icon_name: "clipboard-line",
                        if: allowed_to?(:index, :templates),
                        active: (
                          is_active_link?(decidim_admin_templates.questionnaire_templates_path) ||
                            is_active_link?(decidim_admin_templates.root_path)
                        ) && !is_active_link?(decidim_admin_templates.block_user_templates_path)

          menu.add_item :user_reports,
                        I18n.t("template_types.block_user", scope: "decidim.templates"),
                        decidim_admin_templates.block_user_templates_path,
                        icon_name: "user-forbid-line",
                        if: allowed_to?(:index, :templates),
                        active: is_active_link?(decidim_admin_templates.block_user_templates_path)
        end
      end

      initializer "decidim_templates_admin.menu" do
        Decidim.menu :admin_menu do |menu|
          menu.add_item :questionnaire_templates,
                        I18n.t("menu.templates", scope: "decidim.admin", default: "Templates"),
                        decidim_admin_templates.questionnaire_templates_path,
                        icon_name: "file-copy-line",
                        position: 12,
                        active: is_active_link?(decidim_admin_templates.root_path),
                        if: allowed_to?(:read, :templates)
        end
      end

      def load_seed
        nil
      end
    end
  end
end

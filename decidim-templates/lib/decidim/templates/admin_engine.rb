# frozen_string_literal: true

module Decidim
  module Templates
    # This is the engine that runs on the public interface of `Templates`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Templates::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        resources :questionnaire_templates do
          member do
            post :copy
            
            resource :questionnaire, module: "questionnaire_templates"
          end
          
          collection do
            post :skip
            post :choose
            get :preview
          end
        end

        root to: "questionnaire_templates#index"
      end

      initializer "decidim_templates.admin_mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::Templates::AdminEngine, at: "/admin/templates", as: "decidim_admin_templates"
        end
      end

      initializer "decidim_templates.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.templates", scope: "decidim.admin", default: "Templates"),
                    decidim_admin_templates.questionnaire_templates_url,
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

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
        scope "templates" do
          %w(questionnaire).each do |model_name|
            resources :"#{model_name}_templates"
          end
        end

        root to: "templates#index"
      end

      initializer "decidim_templates.admin_mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::Templates::AdminEngine, at: "/admin/templates", as: "decidim_admin_templates"
        end
      end

      initializer "decidim_templates.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.templates", scope: "decidim.admin", default: "Templates"),
                    decidim_admin_templates.root_url,
                    icon_name: "document",
                    position: 12,
                    # if: allowed_to?(:read, :template), # TODO: investigate
                    active: :inclusive # TODO! # active: is_active_link?(decidim_admin_templates.config_path(:editors), :inclusive)
        end
      end

      def load_seed
        nil
      end
    end
  end
end

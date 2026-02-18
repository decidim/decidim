# frozen_string_literal: true

module Decidim
  module System
    class Menu
      def self.register_system_menu!
        Decidim.menu :system_menu do |menu|
          menu.add_item :root,
                        I18n.t("menu.dashboard", scope: "decidim.system"),
                        decidim_system.root_path,
                        position: 1,
                        active: ["decidim/system/dashboard" => :show]
          if Decidim.module_installed?(:api)
            menu.add_item :api_credentials,
                          I18n.t("menu.api_credentials", scope: "decidim.system"),
                          decidim_system.api_users_path,
                          position: 2,
                          active: ["decidim/system/api_users"]
          end
          menu.add_item :organizations,
                        I18n.t("menu.organizations", scope: "decidim.system"),
                        decidim_system.organizations_path,
                        position: 2,
                        active: :inclusive

          menu.add_item :admins,
                        I18n.t("menu.admins", scope: "decidim.system"),
                        decidim_system.admins_path,
                        position: 3,
                        active: :inclusive

          menu.add_item :oauth_applications,
                        I18n.t("menu.oauth_applications", scope: "decidim.system"),
                        decidim_system.oauth_applications_path,
                        position: 4,
                        active: [%w(decidim/system/oauth_applications), []]
        end
      end
    end
  end
end

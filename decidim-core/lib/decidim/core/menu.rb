# frozen_string_literal: true

module Decidim
  module Core
    class Menu
      def self.register_menu!
        Decidim.menu :menu do |menu|
          menu.add_item :root,
                        I18n.t("menu.home", scope: "decidim"),
                        decidim.root_path,
                        position: 1,
                        active: :exclusive
        end
      end

      def self.register_mobile_menu!
        Decidim.menu :mobile_menu do |menu|
          menu.add_item :root,
                        I18n.t("menu.home", scope: "decidim"),
                        decidim.root_path,
                        position: 1,
                        active: :exclusive

          menu.add_item :help,
                        I18n.t("menu.help", scope: "decidim"),
                        decidim.pages_path(locale: current_locale),
                        position: 10,
                        active: :exclusive
        end
      end

      def self.register_user_menu!
        Decidim.menu :user_menu do |menu|
          menu.add_item :account,
                        t("account", scope: "layouts.decidim.user_profile"),
                        decidim.account_path,
                        position: 1.0,
                        active: :exact

          menu.add_item :notifications_settings,
                        t("notifications_settings", scope: "layouts.decidim.user_profile"),
                        decidim.notifications_settings_path,
                        position: 1.1

          if available_verification_workflows.any?
            menu.add_item :authorizations,
                          t("authorizations", scope: "layouts.decidim.user_profile"),
                          decidim_verifications.authorizations_path,
                          position: 1.2
          end

          menu.add_item :download_your_data,
                        t("my_data", scope: "layouts.decidim.user_profile"),
                        decidim.download_your_data_path,
                        position: 1.5

          menu.add_item :delete_account,
                        t("delete_my_account", scope: "layouts.decidim.user_profile"),
                        decidim.delete_account_path,
                        position: 999,
                        active: :exact
        end
      end
    end
  end
end

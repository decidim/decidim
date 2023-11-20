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

          menu.add_item :pages,
                        I18n.t("menu.help", scope: "decidim"),
                        decidim.pages_path,
                        position: 7,
                        active: :inclusive
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

          if current_organization.user_groups_enabled? && user_groups.any?
            menu.add_item :own_user_groups,
                          t("user_groups", scope: "layouts.decidim.user_profile"),
                          decidim.own_user_groups_path,
                          position: 1.3
          end

          menu.add_item :user_interests,
                        t("my_interests", scope: "layouts.decidim.user_profile"),
                        decidim.user_interests_path,
                        position: 1.4

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

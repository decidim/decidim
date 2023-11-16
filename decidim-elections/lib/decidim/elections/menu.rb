# frozen_string_literal: true

module Decidim
  module Elections
    class Menu
      def self.register_user_menu!
        Decidim.menu :user_menu do |menu|
          menu.add_item :decidim_elections_trustee_zone,
                        I18n.t("menu.trustee_zone", scope: "decidim.elections.trustee_zone"),
                        decidim.decidim_elections_trustee_zone_path,
                        active: :inclusive,
                        if: Decidim::Elections::Trustee.trustee?(current_user)
        end
      end

      def self.register_participatory_space_registry_manifests!
        Decidim.participatory_space_registry.manifests.each do |participatory_space|
          menu_id = :"admin_#{participatory_space.name.to_s.singularize}_menu"
          Decidim.menu menu_id do |menu|
            component = current_participatory_space.try(:components)&.find_by(manifest_name: :elections)
            next unless component

            link = Decidim::EngineRouter.admin_proxy(component).trustees_path(locale: I18n.locale)

            has_election_components = current_participatory_space.components.select { |c| c.manifest_name == "elections" }.any?

            menu.add_item :trustees,
                          I18n.t("trustees", scope: "decidim.elections.admin.menu"),
                          link,
                          if: has_election_components && (allowed_to?(:manage, :trustees) || current_user.admin?),
                          icon_name: "safe-line",
                          position: 100,
                          active: is_active_link?(link)
          end
        end
      end
    end
  end
end

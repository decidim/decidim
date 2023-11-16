# frozen_string_literal: true

module Decidim
  module Votings
    class PollingOfficerZoneMenu
      def self.register_user_menu!
        Decidim.menu :user_menu do |menu|
          menu.add_item :decidim_votings_polling_officer_zone,
                        I18n.t("menu.polling_officer_zone", scope: "decidim.votings.polling_officer_zone"),
                        decidim.decidim_votings_polling_officer_zone_path,
                        active: :inclusive,
                        if: Decidim::Votings::PollingOfficer.polling_officer?(current_user)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Votings
    class CensusMenu
      def self.register_admin_voting_menu!
        Decidim.menu :admin_voting_menu do |menu|
          menu.add_item :voting_census,
                        I18n.t("census", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_census_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.voting_census_path(current_participatory_space)),
                        icon_name: "mail-line",
                        if: allowed_to?(:manage, :census)
        end
      end
    end
  end
end

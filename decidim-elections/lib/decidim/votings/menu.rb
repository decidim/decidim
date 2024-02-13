# frozen_string_literal: true

module Decidim
  module Votings
    class Menu
      def self.register_menu!
        Decidim.menu :menu do |menu|
          menu.add_item :votings,
                        I18n.t("menu.votings", scope: "decidim"),
                        decidim_votings.votings_path,
                        position: 2.6,
                        if: Decidim::Votings::Voting.where(organization: current_organization).published.any?,
                        active: :inclusive
        end
      end

      def self.register_home_content_block_menu!
        Decidim.menu :home_content_block_menu do |menu|
          menu.add_item :votings,
                        I18n.t("menu.votings", scope: "decidim"),
                        decidim_votings.votings_path,
                        position: 40,
                        if: Decidim::Votings::Voting.where(organization: current_organization).published.any?,
                        active: :inclusive
        end
      end

      def self.register_admin_menu_modules!
        Decidim.menu :admin_menu_modules do |menu|
          menu.add_item :votings,
                        I18n.t("menu.votings", scope: "decidim.votings.admin"),
                        decidim_admin_votings.votings_path,
                        icon_name: "mail-line",
                        position: 2.6,
                        active: :inclusive,
                        if: allowed_to?(:enter, :space_area, space_name: :votings)
        end
      end

      def self.register_admin_votings_components_menu!
        Decidim.menu :admin_votings_components_menu do |menu|
          current_participatory_space.components.each do |component|
            caption = decidim_escape_translated(component.name)
            caption += content_tag(:span, component.primary_stat, class: "component-counter") if component.primary_stat.present?

            menu.add_item [component.manifest_name, component.id].join("_"),
                          caption.html_safe,
                          manage_component_path(component),
                          active: is_active_link?(manage_component_path(component)) ||
                                  is_active_link?(decidim_admin_votings.edit_component_path(current_participatory_space, component)) ||
                                  is_active_link?(decidim_admin_votings.edit_component_permissions_path(current_participatory_space, component)) ||
                                  participatory_space_active_link?(component),
                          if: component.manifest.admin_engine # && user_role_config.component_is_accessible?(component.manifest_name)
          end
        end
      end

      def self.register_votings_admin_attachments_menu!
        Decidim.menu :votings_admin_attachments_menu do |menu|
          menu.add_item :voting_attachments,
                        I18n.t("attachment_files", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_attachments_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.voting_attachments_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment, voting: current_participatory_space),
                        icon_name: "attachment-line"
          menu.add_item :voting_attachment_collections,
                        I18n.t("attachment_collections", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_attachment_collections_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.voting_attachment_collections_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment_collection, voting: current_participatory_space),
                        icon_name: "folder-line"
        end
      end

      def self.register_decidim_votings_monitoring_committee_menu!
        Decidim.menu :decidim_votings_monitoring_committee_menu do |menu|
          menu.add_item :voting_monitoring_committee_members,
                        I18n.t("monitoring_committee_members", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_monitoring_committee_members_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.voting_monitoring_committee_members_path(current_participatory_space)),
                        if: allowed_to?(:read, :monitoring_committee_members)
          menu.add_item :monitoring_committee_polling_station_closures,
                        I18n.t("monitoring_committee_polling_station_closures", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_monitoring_committee_polling_station_closures_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.voting_monitoring_committee_polling_station_closures_path(current_participatory_space)),
                        if: allowed_to?(:read, :monitoring_committee_polling_station_closures, voting: current_participatory_space)
          menu.add_item :monitoring_committee_verify_elections,
                        I18n.t("monitoring_committee_verify_elections", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_monitoring_committee_verify_elections_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.voting_monitoring_committee_verify_elections_path(current_participatory_space)),
                        if: allowed_to?(:read, :monitoring_committee_verify_elections, voting: current_participatory_space)
          menu.add_item :monitoring_committee_election_results,
                        I18n.t("monitoring_committee_election_results", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_monitoring_committee_election_results_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.voting_monitoring_committee_election_results_path(current_participatory_space)),
                        if: allowed_to?(:read, :monitoring_committee_election_results, voting: current_participatory_space)
        end
      end

      def self.register_admin_voting_menu!
        Decidim.menu :admin_voting_menu do |menu|
          menu.add_item :edit_voting,
                        I18n.t("info", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.edit_voting_path(current_participatory_space),
                        icon_name: "information-line",
                        if: allowed_to?(:edit, :voting, voting: current_participatory_space)

          menu.add_item :edit_voting_landing_page,
                        I18n.t("landing_page", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.edit_voting_landing_page_path(current_participatory_space),
                        icon_name: "layout-masonry-line",
                        if: allowed_to?(:update, :landing_page)

          menu.add_item :components,
                        I18n.t("components", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.components_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_votings.components_path(current_participatory_space),
                                                ["decidim/votings/admin/components", %w(index new edit)]),
                        icon_name: "tools-line",
                        if: allowed_to?(:read, :components, voting: current_participatory_space),
                        submenu: { target_menu: :admin_votings_components_menu }

          menu.add_item :attachments,
                        I18n.t("attachments", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_attachments_path(current_participatory_space),
                        icon_name: "attachment-2",
                        active: is_active_link?(decidim_admin_votings.voting_attachments_path(current_participatory_space)) ||
                                is_active_link?(decidim_admin_votings.voting_attachment_collections_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment, voting: current_participatory_space) ||
                            allowed_to?(:read, :attachment_collection, voting: current_participatory_space)

          menu.add_item :voting_polling_stations,
                        I18n.t("polling_stations", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_polling_stations_path(current_participatory_space),
                        icon_name: "mail-line",
                        if: !current_participatory_space.online_voting? && allowed_to?(:read, :polling_stations)

          menu.add_item :voting_polling_officers,
                        I18n.t("polling_officers", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_polling_officers_path(current_participatory_space),
                        icon_name: "mail-line",
                        if: !current_participatory_space.online_voting? && allowed_to?(:read, :polling_officers)

          menu.add_item :voting_monitoring_committee,
                        I18n.t("monitoring_committee", scope: "decidim.votings.admin.menu.votings_submenu"),
                        "#",
                        icon_name: "mail-line",
                        active: false,
                        if: !current_participatory_space.online_voting? && allowed_to?(:read, :monitoring_committee_menu, voting: current_participatory_space),
                        submenu: { target_menu: :decidim_votings_monitoring_committee_menu }

          menu.add_item :voting_ballot_styles,
                        I18n.t("ballot_styles", scope: "decidim.votings.admin.menu.votings_submenu"),
                        decidim_admin_votings.voting_ballot_styles_path(current_participatory_space),
                        icon_name: "mail-line",
                        if: allowed_to?(:read, :ballot_styles)
        end
      end
    end
  end
end

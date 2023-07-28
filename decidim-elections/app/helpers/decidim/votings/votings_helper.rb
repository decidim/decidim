# frozen_string_literal: true

module Decidim
  module Votings
    module VotingsHelper
      include Decidim::CheckBoxesTreeHelper

      def date_filter_values
        TreeNode.new(
          TreePoint.new("", filter_text_for(t("votings.filters.all", scope: "decidim.votings"))),
          [
            TreePoint.new("active", filter_text_for(t("votings.filters.active", scope: "decidim.votings"))),
            TreePoint.new("upcoming", filter_text_for(t("votings.filters.upcoming", scope: "decidim.votings"))),
            TreePoint.new("finished", filter_text_for(t("votings.filters.finished", scope: "decidim.votings")))
          ]
        )
      end

      def filter_sections
        @filter_sections ||= [{ method: :with_any_date, collection: date_filter_values, label_scope: "decidim.votings.votings.filters", id: "date" }]
      end

      def voting_nav_items(participatory_space)
        components = participatory_space.components.published.or(Decidim::Component.where(id: try(:current_component)))

        (
          [
            {
              name: t("layouts.decidim.voting_navigation.voting_menu_item"),
              url: decidim_votings.voting_path(participatory_space),
              active: is_active_link?(decidim_votings.voting_path(participatory_space), :exclusive)
            },
            if participatory_space.check_census_enabled?
              {
                name: t("layouts.decidim.voting_navigation.check_census"),
                url: decidim_votings.voting_check_census_path(participatory_space),
                active: is_active_link?(decidim_votings.voting_check_census_path(participatory_space), :exclusive)
              }
            end
          ] + components.map do |component|
            {
              name: translated_attribute(component.name),
              url: main_component_path(component),
              active: is_active_link?(main_component_path(component), :inclusive) && !is_active_link?("election_log", /election_log$/)
            }
          end +
          [
            {
              name: t("layouts.decidim.voting_navigation.election_log"),
              url: decidim_votings.voting_elections_log_path(participatory_space),
              active: is_active_link?(decidim_votings.voting_elections_log_path(participatory_space), :exclusive) || is_active_link?("election_log", /election_log$/)
            }
          ]
        ).compact
      end
    end
  end
end

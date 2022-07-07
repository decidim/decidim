# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      module LandingPage
        class HeaderCell < Decidim::ViewModel
          include Cell::ViewModel::Partial
          include Decidim::LayoutHelper
          include Browser::ActionController
          include Decidim::ComponentPathHelper
          include ActiveLinkTo

          delegate :current_participatory_space,
                   to: :controller

          private

          def start_time
            content_tag :span, title: t("activemodel.attributes.voting.start_time") do
              format_date(current_participatory_space.start_time)
            end
          end

          def end_time
            content_tag :span, title: t("activemodel.attributes.voting.end_time") do
              format_date(current_participatory_space.end_time)
            end
          end

          def format_date(time)
            if time
              l(time.to_date, format: :decidim_short)
            else
              t("decidim.votings.votings_m.unspecified")
            end
          end

          def voting_dates
            "#{start_time} — #{end_time}"
          end

          def translated_button_text
            return unless model

            @translated_button_text ||= translated_attribute(model.settings.button_text)
          end

          def translated_button_url
            return unless model

            @translated_button_url ||= translated_attribute(model.settings.button_url)
          end

          def cta_button
            return unless model

            link_to translated_button_text, translated_button_url, class: "button button--sc expanded", title: translated_button_text
          end

          # component navigation

          def components
            @components ||= current_participatory_space.components
                                                       .published
                                                       .or(Decidim::Component.where(id: try(:current_component)))
          end

          def navigation_items
            (
              [
                {
                  name: t("layouts.decidim.voting_navigation.voting_menu_item"),
                  url: decidim_votings.voting_path(current_participatory_space),
                  active: is_active_link?(decidim_votings.voting_path(current_participatory_space), :exclusive)
                },
                if current_participatory_space.check_census_enabled?
                  {
                    name: t("layouts.decidim.voting_navigation.check_census"),
                    url: decidim_votings.voting_check_census_path(current_participatory_space),
                    active: is_active_link?(decidim_votings.voting_check_census_path(current_participatory_space), :exclusive)
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
                  url: decidim_votings.voting_elections_log_path(current_participatory_space),
                  active: is_active_link?(decidim_votings.voting_elections_log_path(current_participatory_space), :exclusive) || is_active_link?("election_log", /election_log$/)
                }
              ]
            ).compact
          end

          def decidim_votings
            Decidim::Votings::Engine.routes.url_helpers
          end
        end
      end
    end
  end
end

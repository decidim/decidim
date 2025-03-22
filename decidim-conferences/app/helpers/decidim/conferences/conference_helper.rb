# frozen_string_literal: true

module Decidim
  # A Helper to render conferences.
  module Conferences
    module ConferenceHelper
      include PaginateHelper
      include Decidim::AttachmentsHelper

      # Renders the dates of a conference
      #
      def render_date(conference)
        return l(conference.start_date, format: :decidim_with_month_name_short) if conference.start_date == conference.end_date

        "#{l(conference.start_date, format: :decidim_with_month_name_short)} - #{l(conference.end_date, format: :decidim_with_month_name_short)}"
      end

      # Items to display in the navigation of a conference
      #
      def conference_nav_items(participatory_space)
        [].tap do |items|
          if participatory_space.speakers.published.exists?
            items << {
              name: t("layouts.decidim.conferences_nav.conference_speaker_menu_item"),
              url: decidim_conferences.conference_conference_speakers_path(participatory_space, locale: current_locale)
            }
          end

          meeting_components = participatory_space.components.published.where(manifest_name: "meetings")
          other_components = participatory_space.components.published.where.not(manifest_name: "meetings")

          meeting_components.each do |component|
            next unless Decidim::Meetings::Meeting.where(component:).published.not_hidden.visible_for(current_user).exists?

            items << {
              name: decidim_escape_translated(component.name),
              url: decidim_conferences.conference_conference_program_path(participatory_space, locale: current_locale, id: component.id)
            }
          end

          if participatory_space.partners.exists?
            items << {
              name: t("layouts.decidim.conferences_nav.conference_partners_menu_item"),
              url: decidim_conferences.conference_path(participatory_space, locale: current_locale, anchor: "conference-partners-main_promotor")
            }
          end

          if meeting_components.exists?
            items << {
              name: t("layouts.decidim.conferences_nav.venues"),
              url: decidim_conferences.conference_path(participatory_space, locale: current_locale, anchor: "venues")
            }
          end

          other_components.each do |component|
            items << {
              name: decidim_escape_translated(component.name),
              url: main_component_path(component)
            }
          end

          if participatory_space.attachments.any? || participatory_space.media_links.any?
            items << {
              name: t("layouts.decidim.conferences_nav.media"),
              url: decidim_conferences.conference_media_path(participatory_space, locale: current_locale)
            }
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      module ElectionsHelper
        def census_count(election)
          election.census&.count(election).to_i
        end

        def preview_users(election)
          return unless election.census_ready?

          @preview_users ||= election.census&.users(election, 0)&.map do |user|
            present_user(election, user)
          end
        end

        def present_user(election, user)
          return user unless election.census

          election.census.user_presenter.constantize.new(user)
        end

        def election_status_with_label(election)
          status, css_class = election_status_and_class(election)

          content_tag(:span, status, class: css_class)
        end

        def formatted_datetime(datetime)
          l(datetime, format: :short_with_time)
        end

        def election_action_button(election)
          if election.manual_start? && !election.started?
            button_tag(
              t("decidim.elections.admin.dashboard.calendar.start_election"),
              class: "button button__xs button__secondary small"
            )
          elsif election.started? && !election.vote_ended?
            button_tag(
              t("decidim.elections.admin.dashboard.calendar.end_election"),
              class: "button button__xs button__secondary small"
            )
          else
            nil
          end
        end


        private

        def election_status_and_class(election)
          status = election.status.current_status

          case status
          when :scheduled
            [t("decidim.elections.status.scheduled"), "secondary label"]
          when :ongoing
            [t("decidim.elections.status.ongoing"), "warning label"]
          when :ended
            [t("decidim.elections.status.ended"), "success label"]
          when :published_results
            [t("decidim.elections.status.published_results"), "success label"]
          end
        end
      end
    end
  end
end

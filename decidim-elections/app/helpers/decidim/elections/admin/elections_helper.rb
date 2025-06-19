# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      module ElectionsHelper
        include Decidim::ApplicationHelper

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

        def election_status_action_data(election)
          if election.scheduled? && election.manual_start?
            {
              label: t("decidim.elections.admin.dashboard.calendar.start_election"),
              status_action: "start"
            }
          elsif election.ongoing?
            {
              label: t("decidim.elections.admin.dashboard.calendar.end_election"),
              status_action: "end"
            }
          end
        end

        def publish_button_for(election, question)
          button_to update_status_election_path(election),
                    method: :put,
                    params: { status_action: "publish_results" },
                    disabled: !election.results_publishable_for?(question),
                    class: "button button__sm button__secondary" do
            t("decidim.elections.admin.dashboard.results.publish_button")
          end
        end

        private

        def election_status_and_class(election)
          css_class = {
            scheduled: "secondary label",
            ongoing: "warning label",
            ended: "success label",
            results_published: "success label"
          }[election.status.current_status] || "default label"

          [election.localized_status, css_class]
        end
      end
    end
  end
end

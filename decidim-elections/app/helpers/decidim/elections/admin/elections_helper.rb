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
          content_tag(:span,
                      I18n.t("decidim.elections.status.#{election.current_status}"),
                      class: "#{election.current_status} label")
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

        def enable_question_voting_button(question)
          return if question.published_results?

          if question.voting_enabled?
            return content_tag(:div, class: "status-label") do
              content_tag(:span, t("decidim.elections.status.voting_enabled"), class: "label warning spinner")
            end
          end

          return unless question.can_enable_voting?

          button_to update_question_status_election_path(question.election),
                    method: :put,
                    params: { status_action: "enable_voting", question_id: question.id },
                    class: "button button__sm button__secondary" do
            t("decidim.elections.admin.dashboard.results.start_question_button")
          end
        end

        def publish_question_button(question)
          if question.published_results?
            return content_tag(:div, class: "status-label") do
              content_tag(:span, t("decidim.elections.status.results_published"), class: "label success")
            end
          end

          button_to update_question_status_election_path(question.election),
                    method: :put,
                    params: { status_action: "publish_results", question_id: question.id },
                    disabled: !question&.publishable_results?,
                    class: "button button__sm button__secondary" do
            t("decidim.elections.admin.dashboard.results.publish_button")
          end
        end
      end
    end
  end
end

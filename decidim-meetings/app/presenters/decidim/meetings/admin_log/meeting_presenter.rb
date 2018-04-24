# frozen_string_literal: true

module Decidim
  module Meetings
    module AdminLog
      # This class holds the logic to present a `Decidim::Meetings::Meeting`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    MeetingPresenter.new(action_log, view_helpers).present
      class MeetingPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            address: :string,
            attendees_count: :integer,
            attending_organizations: :string,
            closed_at: :date,
            closing_report: :i18n,
            description: :i18n,
            end_date: :date,
            location: :i18n,
            location_hints: :i18n,
            start_date: :date,
            title: :i18n,
            private_meeting: :boolean,
            transparent: :boolean,
            organizer_id: "Decidim::Meetings::AdminLog::ValueTypes::OrganizerPresenter"
          }
        end

        def action_string
          case action
          when "close", "create", "delete", "export_registrations", "update"
            "decidim.meetings.admin_log.meeting.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.meeting"
        end

        def has_diff?
          action == "close" || super
        end
      end
    end
  end
end

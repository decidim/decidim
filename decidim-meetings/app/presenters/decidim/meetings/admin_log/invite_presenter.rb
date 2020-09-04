# frozen_string_literal: true

module Decidim
  module Meetings
    module AdminLog
      # This class holds the logic to present a `Decidim::Meetings::Invite`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    InvitePresenter.new(action_log, view_helpers).present
      class InvitePresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.meetings.admin_log.invite.#{action}"
          else
            super
          end
        end

        # Tries to use the attendee name from the invitation (resource).
        # If invitation does not exist anymore use the one in extras.
        def i18n_params
          attendee_name = action_log.resource ? action_log.resource.user.name : action_log.extra["attendee_name"]
          super.merge(
            # before Decidim v0.23.0 attendee_name was not being copied into the extras so it may be nil
            attendee_name: attendee_name || "????"
          )
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Conferences
    module AdminLog
      # This class holds the logic to present a `Decidim::Conferences::Invite`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ConferenceInvitePresenter.new(action_log, view_helpers).present
      class ConferenceInvitePresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.conferences.admin_log.invite.#{action}"
          else
            super
          end
        end

        def i18n_params
          super.merge(
            attendee_name: action_log.resource.user.name
          )
        end
      end
    end
  end
end

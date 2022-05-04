# frozen_string_literal: true

module Decidim
  module Votings
    module AdminLog
      # This class holds the logic to present a `Decidim::Votings::Voting`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    PollingStationPresenter.new(action_log, view_helpers).present
      class PollingStationPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.votings.admin_log.polling_station.#{action}"
          else
            super
          end
        end
      end
    end
  end
end

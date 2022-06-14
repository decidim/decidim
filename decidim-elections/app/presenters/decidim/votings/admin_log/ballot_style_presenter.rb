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
      #    BallotStylePresenter.new(action_log, view_helpers).present
      class BallotStylePresenter < Decidim::Log::BasePresenter
        private

        def i18n_params
          super.merge(
            ballot_style_code: ballot_style_code.to_s
          )
        end

        def ballot_style_code
          action_log&.resource&.code || action_log.extra["code"]
        end

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.votings.admin_log.ballot_style.#{action}"
          else
            super
          end
        end
      end
    end
  end
end

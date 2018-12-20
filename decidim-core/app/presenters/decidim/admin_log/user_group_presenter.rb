# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::UserGroup`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    UserGroupPresenter.new(action_log, view_helpers).present
    class UserGroupPresenter < Decidim::Log::BasePresenter
      private

      def has_diff?
        false
      end

      def action_string
        case action
        when "verify", "verify_via_csv", "reject"
          "decidim.admin_log.user_group.#{action}"
        else
          super
        end
      end
    end
  end
end

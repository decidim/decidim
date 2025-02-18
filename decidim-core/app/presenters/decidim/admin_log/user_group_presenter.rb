# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::UserGroup`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you should not need to call this class
    # directly, but here is an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    UserGroupPresenter.new(action_log, view_helpers).present
    class UserGroupPresenter < BaseUserPresenter
      private

      def action_string
        case action
        when "verify", "verify_via_csv", "reject", "block", "unblock", "bulk_block", "bulk_unblock", "bulk_ignore"
          "decidim.admin_log.user_group.#{action}"
        else
          super
        end
      end

      def diff_actions
        %w(bulk_block bulk_unblock bulk_ignore)
      end
    end
  end
end

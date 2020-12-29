# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::ImpersonationLog`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    ImpersonationLogPresenter.new(action_log, view_helpers).present
    class ImpersonationLogPresenter < Decidim::Log::BasePresenter
      alias h view_helpers

      private

      def action_string
        case action
        when "manage"
          "decidim.admin_log.impersonation_log.#{action}"
        else
          super
        end
      end

      def i18n_params
        super.merge(
          reason: action_log.extra["reason"]
        )
      end

      def resource_presenter
        @resource_presenter ||= Decidim::Log::UserPresenter.new(action_log.resource.user, h, action_log.extra["resource"])
      end
    end
  end
end

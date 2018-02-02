# frozen_string_literal: true

module Decidim
  module Accountability
    module AdminLog
      # This class holds the logic to present a `Decidim::Accountability::Result`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ResultPresenter.new(action_log, view_helpers).present
      class ResultPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "create"
            "decidim.accountability.admin_log.result.create"
          when "update"
            "decidim.accountability.admin_log.result.update"
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Forms
    module AdminLog
      # This class holds the logic to present a `Decidim::Forms::Question`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you should not need to call this class
      # directly, but here is an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    QuestionPresenter.new(action_log, view_helpers).present
      class QuestionPresenter < Decidim::Log::BasePresenter
        private

        # i18n-tasks-use t("decidim.forms.admin_log.question.publish_responses")
        # i18n-tasks-use t("decidim.forms.admin_log.question.unpublish_responses")
        def action_string
          case action
          when "publish_responses", "unpublish_responses"
            "decidim.forms.admin_log.question.#{action}"
          else
            super
          end
        end
      end
    end
  end
end

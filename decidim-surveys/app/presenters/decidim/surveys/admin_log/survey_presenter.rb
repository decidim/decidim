# frozen_string_literal: true

module Decidim
  module Surveys
    module AdminLog
      # This class holds the logic to present a `Decidim::Surveys::Survey`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you should not need to call this class
      # directly, but here is an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    SurveyPresenter.new(action_log, view_helpers).present
      class SurveyPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "delete", "create", "update", "publish"
            "decidim.surveys.admin_log.survey.#{action}"
          else
            super
          end
        end
      end
    end
  end
end

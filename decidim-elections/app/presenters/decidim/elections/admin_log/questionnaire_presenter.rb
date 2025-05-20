# frozen_string_literal: true

module Decidim
  module Elections
    module AdminLog
      # This class holds the logic to present a `Decidim::Elections::Questionnaire`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you should not need to call this class
      # directly, but here is an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    QuestionnairePresenter.new(action_log, view_helpers).present
      class QuestionnairePresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "update"
            "decidim.elections.admin_log.questionnaire.#{action}"
          else
            super
          end
        end

        def resource_presenter
          @resource_presenter ||= Decidim::Log::ResourcePresenter.new(action_log.resource.questionnaire_for, h, action_log.resource.questionnaire_for)
        end

        def i18n_params
          super.merge(election_name: resource_presenter.try(:present))
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      module Concerns
        # Url helper for HasQuestionnaireAnswers controller concern
        #
        module HasQuestionnaireAnswersUrlHelper
          def self.included(base)
            base.helper_method :questionnaire_url, :questionnaire_participants_url,
                               :questionnaire_participant_answers_url, :questionnaire_export_response_url
          end

          # You can implement this method in your controller to change the URL
          # where the questionnaire can be edited.
          def questionnaire_url
            url_for(questionnaire.questionnaire_for)
          end

          # You can implement this method in your controller to change the URL
          # where the questionnaire participants' info will be shown.
          def questionnaire_participants_url
            url_for([:index, questionnaire.questionnaire_for, { format: nil }])
          end

          # You can implement this method in your controller to change the URL
          # where the user's questionnaire answers will be shown.
          def questionnaire_participant_answers_url(session_token)
            url_for([:show, questionnaire.questionnaire_for, { session_token: }])
          end

          def questionnaire_export_response_url(session_token)
            url_for([:export_response, questionnaire.questionnaire_for, { session_token:, format: "pdf" }])
          end
        end
      end
    end
  end
end

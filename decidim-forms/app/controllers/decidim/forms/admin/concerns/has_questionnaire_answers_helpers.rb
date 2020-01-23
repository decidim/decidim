# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      module Concerns
        module HasQuestionnaireAnswersHelpers
          # You can implement this method in your controller to change the URL
          # where the questionnaire can be edited.
          def questionnaire_url
            url_for(questionnaire.questionnaire_for)
          end

          # You can implement this method in your controller to change the URL
          # where the questionnaire participants' info will be shown.
          def questionnaire_participants_url
            url_for([:index, questionnaire.questionnaire_for, format: nil])
          end

          # You can implement this method in your controller to change the URL
          # where the user's questionnaire answers will be shown.
          def questionnaire_participant_answers_url(session_token)
            url_for([:show, questionnaire.questionnaire_for, session_token: session_token])
          end

          def questionnaire_export_url
            url_for([:export, questionnaire.questionnaire_for, format: "pdf"])
          end

          def questionnaire_export_response_url(session_token)
            url_for([:export_response, questionnaire.questionnaire_for, session_token: session_token, format: "pdf"])
          end

          def prev_url
            return if first?

            token = participant_ids[current_idx - 1]
            questionnaire_participant_answers_url(token)
          end

          def next_url
            return if last?

            token = participant_ids[current_idx + 1]
            questionnaire_participant_answers_url(token)
          end

          def first?
            current_idx.zero?
          end

          def last?
            current_idx == participant_ids.count - 1
          end

          private

          def participant_ids
            @participant_ids ||= collection.pluck(:session_token)
          end

          def current_idx
            participant_ids.index(params[:session_token])
          end
        end
      end
    end
  end
end

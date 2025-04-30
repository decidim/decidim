# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      module Concerns
        # Pagination helper for HasQuestionnaireResponses controller concern
        #
        module HasQuestionnaireResponsesPaginationHelper
          def self.included(base)
            base.helper_method :prev_url, :next_url, :first?, :last?, :current_idx
          end

          def prev_url
            return if first?

            token = participant_ids[current_idx - 1]
            questionnaire_participant_responses_url(token)
          end

          def next_url
            return if last?

            token = participant_ids[current_idx + 1]
            questionnaire_participant_responses_url(token)
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
            participant_ids.index(params[:id])
          end
        end
      end
    end
  end
end

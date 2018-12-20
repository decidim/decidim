# frozen_string_literal: true

module Decidim
  module Surveys
    module Metrics
      # Searches for Participants in the following actions
      #  - Answer a survey (Surveys)
      class SurveyParticipantsMetricMeasure < Decidim::MetricMeasure
        def valid?
          super && @resource.is_a?(Decidim::Component)
        end

        def calculate
          surveys = Decidim::Surveys::Survey.joins(:component, :questionnaire).where(component: @resource)
          questionnaires = Decidim::Forms::Questionnaire.includes(:questionnaire_for)
                                                        .where(questionnaire_for_type: Decidim::Surveys::Survey.name, questionnaire_for_id: surveys.pluck(:id))

          answers = Decidim::Forms::Answer.joins(:questionnaire)
                                          .where(questionnaire: questionnaires)
                                          .where("decidim_forms_answers.created_at <= ?", end_time)

          {
            cumulative_users: answers.pluck(:decidim_user_id).uniq,
            quantity_users: answers.where("decidim_forms_answers.created_at >= ?", start_time).pluck(:decidim_user_id).uniq
          }
        end
      end
    end
  end
end

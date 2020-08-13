# frozen_string_literal: true

module Decidim
  module Surveys
    module Metrics
      class AnswersMetricManage < Decidim::MetricManage
        def metric_name
          "survey_answers"
        end

        def save
          query.each do |key, results|
            cumulative_value = results[:cumulative]
            next if cumulative_value.zero?

            quantity_value = results[:quantity] || 0
            space_type, space_id, survey_id = key
            record = Decidim::Metric.find_or_initialize_by(day: @day.to_s, metric_type: @metric_name,
                                                           organization: @organization, decidim_category_id: nil,
                                                           participatory_space_type: space_type, participatory_space_id: space_id,
                                                           related_object_type: Decidim::Surveys::Survey.name, related_object_id: survey_id)
            record.assign_attributes(cumulative: cumulative_value, quantity: quantity_value)
            record.save!
          end
        end

        private

        def query
          return @query if @query

          @query = retrieve_surveys.each_with_object({}) do |survey, grouped_answers|
            answers = Decidim::Forms::Answer.joins(:questionnaire)
                                            .where(questionnaire: retrieve_questionnaires(survey))
                                            .where("decidim_forms_answers.created_at <= ?", end_time)
            next grouped_answers unless answers

            group_key = generate_group_key(survey)
            grouped_answers[group_key] ||= { cumulative: 0, quantity: 0 }
            grouped_answers[group_key][:cumulative] += answers.count
            grouped_answers[group_key][:quantity] += answers.where("decidim_forms_answers.created_at >= ?", start_time).count
          end
          @query
        end

        def retrieve_surveys
          Decidim::Surveys::Survey.where(component: visible_component_ids_from_spaces(retrieve_participatory_spaces))
        end

        def retrieve_questionnaires(survey)
          Decidim::Forms::Questionnaire.includes(:questionnaire_for)
                                       .where(questionnaire_for: survey)
        end

        def generate_group_key(survey)
          participatory_space = survey.participatory_space
          group_key = []
          group_key += [participatory_space.class.name, participatory_space.id]
          group_key += [survey.id]
          group_key
        end
      end
    end
  end
end

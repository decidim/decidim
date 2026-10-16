# frozen_string_literal: true

class BackfillDecidimFormsResponseValues < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  class Response < ApplicationRecord
    self.table_name = "decidim_forms_responses"
  end

  def up
    return if Response.where(value: nil).none?

    questionnaire_ids_to_backfill.each_slice(100) do |ids|
      say_with_time "Backfilling response values for questionnaires #{ids.first}..#{ids.last}" do
        execute text_values_sql(ids)
        execute single_option_values_sql(ids)
        execute list_values_sql(ids)
        execute matrix_single_values_sql(ids)
        execute matrix_multiple_values_sql(ids)
        execute files_values_sql(ids)
      end
    end

    report_responses_without_value
  end

  def down
    Response.where.not(value: nil).update_all(value: nil) # rubocop:disable Rails/SkipsModelValidations
  end

  private

  def questionnaire_ids_to_backfill
    Response.where(value: nil).where.not(decidim_questionnaire_id: nil).order(:decidim_questionnaire_id).distinct.pluck(:decidim_questionnaire_id)
  end

  def responses_with_data
    Response.from("decidim_forms_responses AS responses")
            .joins("LEFT JOIN decidim_forms_questions AS questions ON questions.id = responses.decidim_question_id")
            .where("questions.question_type IS DISTINCT FROM 'title_and_description'")
            .where("#{present_sql("responses.body")} OR #{choices_exist_sql} OR #{attachments_exist_sql}")
  end

  def report_responses_without_value
    without_value = Response.where(value: nil).count
    with_data = responses_with_data.where(responses: { value: nil }).count
    say "#{without_value - with_data} responses without an answer were left without a value"
    say "#{with_data} responses with data were left without a value: question type changed after the response, or question or questionnaire missing"
  end

  def update_sql(ids, type_condition, value_sql)
    <<~SQL.squish
      UPDATE decidim_forms_responses AS responses
      SET value = #{value_sql}
      FROM decidim_forms_questions AS questions
      WHERE questions.id = responses.decidim_question_id
        AND responses.decidim_questionnaire_id IN (#{ids.join(",")}) AND responses.value IS NULL
        AND #{type_condition}
    SQL
  end

  def text_values_sql(ids)
    update_sql(ids, "questions.question_type IN ('short_response', 'long_response') AND #{present_sql("responses.body")}", "to_jsonb(responses.body)")
  end

  def single_option_values_sql(ids)
    update_sql(ids, "questions.question_type = 'single_option' AND #{choices_exist_sql}", <<~SQL.squish)
      (SELECT #{choice_object_sql} FROM #{choices_sql} WHERE choices.decidim_response_id = responses.id ORDER BY choices.id LIMIT 1)
    SQL
  end

  def list_values_sql(ids)
    update_sql(ids, "questions.question_type IN ('multiple_option', 'sorting') AND #{choices_exist_sql}", <<~SQL.squish)
      (SELECT jsonb_agg(#{choice_object_sql} ORDER BY choices.id) FROM #{choices_sql} WHERE choices.decidim_response_id = responses.id)
    SQL
  end

  def matrix_single_values_sql(ids)
    update_sql(ids, "questions.question_type = 'matrix_single' AND #{choices_exist_sql(matrix_row_sql)}", <<~SQL.squish)
      (SELECT jsonb_object_agg(cells.row_id, cells.choice) FROM (
         SELECT DISTINCT ON (choices.decidim_question_matrix_row_id)
                choices.decidim_question_matrix_row_id::text AS row_id, #{choice_object_sql} AS choice
         FROM #{choices_sql}
         WHERE choices.decidim_response_id = responses.id AND #{matrix_row_sql}
         ORDER BY choices.decidim_question_matrix_row_id, choices.id) AS cells)
    SQL
  end

  def matrix_multiple_values_sql(ids)
    update_sql(ids, "questions.question_type = 'matrix_multiple' AND #{choices_exist_sql(matrix_row_sql)}", <<~SQL.squish)
      (SELECT jsonb_object_agg(cells.row_id, cells.choices) FROM (
         SELECT choices.decidim_question_matrix_row_id::text AS row_id, jsonb_agg(#{choice_object_sql} ORDER BY choices.id) AS choices
         FROM #{choices_sql}
         WHERE choices.decidim_response_id = responses.id AND #{matrix_row_sql}
         GROUP BY choices.decidim_question_matrix_row_id) AS cells)
    SQL
  end

  def files_values_sql(ids)
    update_sql(ids, "questions.question_type = 'files' AND #{attachments_exist_sql}", <<~SQL.squish)
      (SELECT jsonb_agg(attachments.id ORDER BY attachments.weight, attachments.id) FROM #{attachments_sql})
    SQL
  end

  def choices_sql
    "decidim_forms_response_choices AS choices LEFT JOIN decidim_forms_response_options AS options ON options.id = choices.decidim_response_option_id"
  end

  def choice_object_sql
    <<~SQL.squish
      jsonb_strip_nulls(jsonb_build_object(
        'option', choices.decidim_response_option_id,
        'text', CASE WHEN #{present_sql("choices.custom_body")} THEN choices.custom_body END,
        'label', CASE WHEN options.id IS NULL THEN choices.body END))
    SQL
  end

  def choices_exist_sql(*conditions)
    "EXISTS (SELECT 1 FROM decidim_forms_response_choices AS choices WHERE #{["choices.decidim_response_id = responses.id", *conditions].join(" AND ")})"
  end

  def matrix_row_sql
    "choices.decidim_question_matrix_row_id IS NOT NULL"
  end

  def attachments_exist_sql
    "EXISTS (SELECT 1 FROM #{attachments_sql})"
  end

  def present_sql(column)
    "#{column} !~ '^[[:space:]]*$'"
  end

  # Attachments keep the "Answer" type until the data migration renaming answers to responses has run
  def attachments_sql
    "decidim_attachments AS attachments WHERE attachments.attached_to_type IN ('Decidim::Forms::Response', 'Decidim::Forms::Answer') AND attachments.attached_to_id = responses.id"
  end
end

# frozen_string_literal: true

class RenameAnswerToResponseInDecidimForms < ActiveRecord::Migration[7.0]
  def change
    rename_index :decidim_forms_response_choices, "index_decidim_forms_answer_choices_answer_id", "index_decidim_forms_response_choices_response_id"
    rename_index :decidim_forms_response_choices, "index_decidim_forms_answer_choices_answer_option_id", "index_decidim_forms_response_choices_response_option_id"

    rename_index :decidim_forms_response_options, "index_decidim_forms_answer_options_question_id", "index_decidim_forms_response_options_question_id"

    rename_index :decidim_forms_responses, "index_decidim_forms_answers_question_id", "index_decidim_forms_responses_question_id"
    rename_index :decidim_forms_responses, "index_decidim_forms_answers_on_decidim_questionnaire_id", "index_decidim_forms_responses_on_decidim_questionnaire_id"
    rename_index :decidim_forms_responses, "index_decidim_forms_answers_on_decidim_user_id", "index_decidim_forms_responses_on_decidim_user_id"
    rename_index :decidim_forms_responses, "index_decidim_forms_answers_on_ip_hash", "index_decidim_forms_responses_on_ip_hash"
    rename_index :decidim_forms_responses, "index_decidim_forms_answers_on_session_token", "index_decidim_forms_responses_on_session_token"

    rename_index :decidim_forms_display_conditions, "decidim_forms_display_condition_answer_option", "decidim_forms_display_condition_response_option"

    rename_table :decidim_forms_answers, :decidim_forms_responses
    rename_table :decidim_forms_answer_choices, :decidim_forms_response_choices
    rename_table :decidim_forms_answer_options, :decidim_forms_response_options

    rename_column :decidim_forms_response_choices, :decidim_answer_id, :decidim_response_id
    rename_column :decidim_forms_response_choices, :decidim_answer_option_id, :decidim_response_option_id

    rename_column :decidim_forms_display_conditions, :decidim_answer_option_id, :decidim_response_option_id

    rename_column :decidim_forms_questions, :answer_options_count, :response_options_count
    rename_column :decidim_forms_questions, :survey_answers_published_at, :survey_responses_published_at
  end
end

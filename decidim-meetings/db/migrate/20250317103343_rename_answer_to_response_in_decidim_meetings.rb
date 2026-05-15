# frozen_string_literal: true

class RenameAnswerToResponseInDecidimMeetings < ActiveRecord::Migration[7.0]
  def change
    rename_index :decidim_meetings_response_choices, "index_decidim_meetings_answer_choices_answer_id", "index_decidim_meetings_response_choices_response_id"
    rename_index :decidim_meetings_response_choices, "index_decidim_meetings_answer_choices_answer_option_id", "index_decidim_meetings_response_choices_response_option_id"
    rename_index :decidim_meetings_response_options, "index_decidim_meetings_answer_options_question_id", "index_decidim_meetings_response_options_question_id"
    rename_index :decidim_meetings_responses, "index_decidim_meetings_answers_question_id", "index_decidim_meetings_responses_question_id"
    rename_index :decidim_meetings_responses, "index_decidim_meetings_answers_on_decidim_questionnaire_id", "index_decidim_meetings_responses_on_decidim_questionnaire_id"

    rename_table :decidim_meetings_answers, :decidim_meetings_responses
    rename_table :decidim_meetings_answer_choices, :decidim_meetings_response_choices
    rename_table :decidim_meetings_answer_options, :decidim_meetings_response_options

    rename_column :decidim_meetings_response_choices, :decidim_answer_id, :decidim_response_id
    rename_column :decidim_meetings_response_choices, :decidim_answer_option_id, :decidim_response_option_id
  end
end

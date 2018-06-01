# frozen_string_literal: true

class CreateMeetingsQuestionnaireAnswerOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_meetings_questionnaire_answer_options do |t|
      t.references :decidim_meetings_questionnaire_question, index: { name: :decidim_meetings_questionnaire_answer_options_on_question_id }
      t.jsonb :body
      t.boolean :free_text
    end
  end
end

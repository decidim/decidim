# frozen_string_literal: true

class CreateMeetingsQuestionnaireAnswerChoices < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_meetings_questionnaire_answer_choices do |t|
      t.references :decidim_meetings_questionnaire_answer, index: { name: :decidim_meetings_questionnaire_answer_choices_answer_id }
      t.references :decidim_meetings_questionnaire_answer_option, index: { name: :decidim_meetings_questionnaire_answer_choices_answer_option_id }

      t.jsonb :body
      t.text :custom_body
      t.integer :position
    end
  end
end

# frozen_string_literal: true

class CreateMeetingsQuestionnaireQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_meetings_questionnaire_questions do |t|
      t.references :decidim_meetings_questionnaire, index: { name: :decidim_meetings_questionnaire_questions_on_questionnaire_id }
      t.string :question_type
      t.integer :position
      t.boolean :mandatory
      t.jsonb :body
      t.jsonb :description
      t.integer :max_choices

      t.timestamps
    end
  end
end

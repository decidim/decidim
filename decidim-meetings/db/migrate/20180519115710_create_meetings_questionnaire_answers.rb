# frozen_string_literal: true

class CreateMeetingsQuestionnaireAnswers < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_meetings_questionnaire_answers do |t|
      t.references :decidim_user, index: { name: :decidim_meetings_questionnaire_answers_on_user_id }
      t.references :decidim_meetings_questionnaire, index: { name: :decidim_meetings_questionnaire_answers_on_questionnaire_id }
      t.references :decidim_meetings_questionnaire_question, index: { name: :decidim_meetings_questionnaire_answers_on_question_id }
      t.text :body

      t.timestamps
    end
  end
end




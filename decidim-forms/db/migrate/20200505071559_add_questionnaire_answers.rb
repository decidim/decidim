# frozen_string_literal: true

class AddQuestionnaireAnswers < ActiveRecord::Migration[5.2]
  class Answer < ApplicationRecord
    self.table_name = :decidim_forms_answers
  end

  class QuestionnaireAnswer < ApplicationRecord
    self.table_name = :decidim_forms_questionnaire_answers
  end

  def change
    create_table :decidim_forms_questionnaire_answers do |t|
      t.integer :decidim_user_id
      t.string :session_token
      t.integer :decidim_questionnaire_id, null: false
      t.timestamps
    end

    Answer
      .distinct
      .pluck(:decidim_user_id, :decidim_questionnaire_id, :session_token)
      .each do |user_id, questionnaire_id, session_token|
        QuestionnaireAnswer.create!(
          session_token: session_token,
          decidim_user_id: user_id,
          decidim_questionnaire_id: questionnaire_id
        )
      end
  end
end

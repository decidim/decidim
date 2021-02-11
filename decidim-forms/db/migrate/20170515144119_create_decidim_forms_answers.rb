# frozen_string_literal: true

class CreateDecidimFormsAnswers < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_forms_answers do |t|
      t.text :body
      t.references :decidim_user, index: true
      t.references :decidim_questionnaire, index: true
      t.references :decidim_question, index: { name: "index_decidim_forms_answers_question_id" }

      t.timestamps
    end
  end
end

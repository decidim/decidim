# frozen_string_literal: true

class CreateDecidimElectionsQuestionsAndAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_elections_questions do |t|
      t.references :questionnaire, null: false, foreign_key: { to_table: :decidim_elections_questionnaires }, index: { name: "index_questions_on_questionnaire_id" }

      t.jsonb :statement, null: false, default: {}
      t.jsonb :description, default: {}
      t.boolean :mandatory, default: false, null: false
      t.string :question_type, null: false, default: "multiple_option"

      t.integer :position
      t.timestamps
    end

    create_table :decidim_elections_answers do |t|
      t.references :question, null: false, foreign_key: { to_table: :decidim_elections_questions }, index: true

      t.jsonb :statement, null: false, default: {}
      t.integer :position
      t.timestamps
    end
  end
end

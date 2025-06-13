# frozen_string_literal: true

class CreateDecidimElectionsQuestionsAndResponseOptions < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_elections_questions do |t|
      t.references :election, null: false, foreign_key: { to_table: :decidim_elections_elections }, index: { name: "index_questions_on_election_id" }

      t.jsonb :body, null: false, default: {}
      t.jsonb :description, default: {}
      t.boolean :mandatory, default: false, null: false
      t.string :question_type, null: false, default: "multiple_option"
      t.integer :position

      t.timestamps
    end

    create_table :decidim_elections_response_options do |t|
      t.references :question, null: false, foreign_key: { to_table: :decidim_elections_questions }, index: { name: "index_response_options_on_question_id" }

      t.jsonb :body, null: false, default: {}
      t.timestamps
    end
  end
end

# frozen_string_literal: true

class CreateDecidimElectionsAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_elections_answers do |t|
      t.references :decidim_elections_question, null: false, index: { name: "decidim_elections_questions_answers" }
      t.jsonb :title, null: false
      t.jsonb :description
      t.integer :weight, null: false, default: 0
    end
  end
end

# frozen_string_literal: true

class CreateDecidimElectionsQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_elections_questions do |t|
      t.references :decidim_elections_election, null: false, index: { name: "decidim_elections_elections_questions" }
      t.jsonb :title, null: false
      t.jsonb :description
      t.integer :max_selections, null: false, default: 1
      t.integer :weight, null: false, default: 0
      t.boolean :random_answers_order, null: false, default: true
    end
  end
end

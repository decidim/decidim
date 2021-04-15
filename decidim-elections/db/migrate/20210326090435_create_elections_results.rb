# frozen_string_literal: true

class CreateElectionsResults < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_elections_results do |t|
      t.integer :votes_count, default: 0, null: false
      t.integer :result_type, index: true

      t.belongs_to :decidim_elections_closure,
                   null: false,
                   index: { name: "index_decidim_elections_results_on_closure_id" }
      t.belongs_to :decidim_elections_answer,
                   null: true,
                   index: { name: "index_decidim_elections_results_on_answer_id" }
      t.belongs_to :decidim_elections_question,
                   null: true,
                   index: { name: "index_decidim_elections_results_on_question_id" }

      t.timestamps
    end
  end
end

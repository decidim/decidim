# frozen_string_literal: true

class ChangeElectionsResults < ActiveRecord::Migration[5.2]
  def change
    change_table :decidim_elections_results do |t|
      t.remove_belongs_to :decidim_elections_answer
      t.remove_belongs_to :decidim_votings_polling_station

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
    end
  end
end

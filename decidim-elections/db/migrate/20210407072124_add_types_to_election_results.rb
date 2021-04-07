# frozen_string_literal: true

class AddTypesToElectionResults < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_elections_results, :result_type, :integer, index: true

    add_reference :decidim_elections_results,
                  :decidim_elections_election,
                  null: true,
                  index: { name: "index_decidim_elections_results_on_election_id" }
    add_reference :decidim_elections_results,
                  :decidim_elections_question,
                  null: true,
                  index: { name: "index_decidim_elections_results_on_question_id" }
    change_column_null :decidim_elections_results,
                       :decidim_elections_answer_id,
                       true
  end
end

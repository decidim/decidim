# frozen_string_literal: true

class CreatePaperBallotResults < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_budgets_paper_ballot_results do |t|
      t.integer :votes, null: false
      t.references :decidim_project, foreign_key: "decidim_project_id", index: { name: :index_decidim_paper_ballot_on_project }
      t.timestamps
    end
  end
end

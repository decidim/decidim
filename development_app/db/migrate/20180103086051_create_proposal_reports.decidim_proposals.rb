# This migration comes from decidim_proposals (originally 20170215113152)
# frozen_string_literal: true

class CreateProposalReports < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_proposals_proposal_reports do |t|
      t.references :decidim_proposal, null: false, index: { name: "decidim_proposals_proposal_result_proposal" }
      t.references :decidim_user, null: false, index: { name: "decidim_proposals_proposal_result_user" }
      t.string :reason, null: false
      t.text :details

      t.timestamps
    end

    add_index :decidim_proposals_proposal_reports, [:decidim_proposal_id, :decidim_user_id], unique: true, name: "decidim_proposals_proposal_report_proposal_user_unique"
  end
end

# This migration comes from decidim_proposals (originally 20180115155220)
# frozen_string_literal: true

class AddIndexCreatedAtProposalNotes < ActiveRecord::Migration[5.1]
  def change
    add_index :decidim_proposals_proposal_notes, :created_at
  end
end

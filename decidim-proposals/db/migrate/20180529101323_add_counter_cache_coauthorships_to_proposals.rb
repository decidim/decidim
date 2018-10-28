# frozen_string_literal: true

class AddCounterCacheCoauthorshipsToProposals < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_proposals_proposals, :coauthorships_count, :integer, null: false, default: 0
    add_index :decidim_proposals_proposals, :coauthorships_count, name: "idx_decidim_proposals_proposals_on_proposal_coauthorships_count"
  end
end

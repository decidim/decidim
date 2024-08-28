# frozen_string_literal: true

class AddDeletedAtToDecidimProposalsProposals < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_proposals_proposals, :deleted_at, :datetime
    add_index :decidim_proposals_proposals, :deleted_at
  end
end

class AddAnswersToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_proposals_proposals, :state, :string, index: true
    add_column :decidim_proposals_proposals, :answered_at, :datetime, index: true
    add_column :decidim_proposals_proposals, :answer, :jsonb
  end
end

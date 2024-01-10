# frozen_string_literal: true

class AddWithdrawnFieldsOnProposals < ActiveRecord::Migration[6.1]
  def up
    add_column :decidim_proposals_proposals, :withdrawn_at, :datetime
    add_column :decidim_proposals_proposals, :withdrawn, :boolean, default: false, null: false
  end

  def down
    remove_column :decidim_proposals_proposals, :withdrawn_at
    remove_column :decidim_proposals_proposals, :withdrawn
  end
end

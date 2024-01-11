# frozen_string_literal: true

class AddWithdrawnFieldsOnProposals < ActiveRecord::Migration[6.1]
  def up
    add_column :decidim_proposals_proposals, :withdrawn_at, :datetime
  end

  def down
    remove_column :decidim_proposals_proposals, :withdrawn_at
  end
end

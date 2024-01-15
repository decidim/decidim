# frozen_string_literal: true

class RemoveStateFromDecidimProposalsProposals < ActiveRecord::Migration[6.1]
  def up
    rename_column :decidim_proposals_proposals, :state, :old_state
  end

  def down
    rename_column :decidim_proposals_proposals, :old_state, :state
  end
end

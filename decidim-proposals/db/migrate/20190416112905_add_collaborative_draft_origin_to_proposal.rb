# frozen_string_literal: true

class AddCollaborativeDraftOriginToProposal < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_proposals_proposals, :collaborative_draft_origin, :boolean, default: false
  end
end

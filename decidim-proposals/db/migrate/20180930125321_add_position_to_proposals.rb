# frozen_string_literal: true

class AddPositionToProposals < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_proposals_proposals, :position, :integer
  end
end

# frozen_string_literal: true

class AddCardImageToProposals < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_proposals_proposals, :card_image, :string
  end
end

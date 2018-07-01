# frozen_string_literal: true

class RemoveAuthorshipsFromProposals < ActiveRecord::Migration[5.1]
  def change
    remove_column :decidim_proposals_proposals, :decidim_author_id, :integer
    remove_column :decidim_proposals_proposals, :decidim_user_group_id, :integer
  end
end

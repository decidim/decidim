# frozen_string_literal: true

class IndexForeignKeysInDecidimInitiativesVotes < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_initiatives_votes, :decidim_user_group_id
    add_index :decidim_initiatives_votes, :hash_id
  end
end

# frozen_string_literal: true

class AddDecidimUserGroupIdToDecidimInitiativesVotes < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_initiatives_votes,
               :decidim_user_group_id, :integer, index: true
  end
end

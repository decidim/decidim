# This migration comes from decidim_proposals (originally 20170120151202)
# frozen_string_literal: true

class AddUserGroupIdToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_proposals_proposals, :decidim_user_group_id, :integer, index: true
  end
end

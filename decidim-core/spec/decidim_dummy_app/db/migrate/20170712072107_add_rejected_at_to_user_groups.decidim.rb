# This migration comes from decidim (originally 20170529150743)
# frozen_string_literal: true

class AddRejectedAtToUserGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_user_groups, :rejected_at, :datetime
  end
end

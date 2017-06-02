# frozen_string_literal: true

class AddRejectedAtToUserGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_user_groups, :rejected_at, :datetime
  end
end

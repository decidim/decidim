# frozen_string_literal: true

class AddPublishedToParticipatorySpacePrivateUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_participatory_space_private_users, :published, :boolean, default: false
  end
end

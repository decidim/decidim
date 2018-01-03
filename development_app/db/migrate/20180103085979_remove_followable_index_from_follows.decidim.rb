# This migration comes from decidim (originally 20170914075721)
# frozen_string_literal: true

class RemoveFollowableIndexFromFollows < ActiveRecord::Migration[5.1]
  def change
    remove_index :decidim_follows, [:decidim_followable_id, :decidim_followable_type]
  end
end

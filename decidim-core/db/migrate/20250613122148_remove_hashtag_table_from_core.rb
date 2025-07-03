# frozen_string_literal: true

class RemoveHashtagTableFromCore < ActiveRecord::Migration[7.2]
  def change
    drop_table :decidim_hashtags, if_exists: true
  end
end

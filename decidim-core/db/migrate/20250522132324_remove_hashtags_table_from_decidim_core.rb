# frozen_string_literal: true

class RemoveHashtagsTableFromDecidimCore < ActiveRecord::Migration[7.0]
  def change
    drop_table :decidim_hashtags, if_exists: true
  end
end

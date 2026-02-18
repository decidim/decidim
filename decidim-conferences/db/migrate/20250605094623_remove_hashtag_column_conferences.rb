# frozen_string_literal: true

class RemoveHashtagColumnConferences < ActiveRecord::Migration[7.1]
  def change
    remove_column :decidim_conferences, :hashtag, :string, if_exists: true
  end
end

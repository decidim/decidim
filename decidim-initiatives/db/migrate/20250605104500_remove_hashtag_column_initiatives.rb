# frozen_string_literal: true

class RemoveHashtagColumnInitiatives < ActiveRecord::Migration[7.1]
  def change
    remove_column :decidim_initiatives, :hashtag, :string, if_exists: true
  end
end

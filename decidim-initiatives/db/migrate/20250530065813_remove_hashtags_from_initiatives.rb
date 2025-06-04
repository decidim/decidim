# frozen_string_literal: true

class RemoveHashtagsFromInitiatives < ActiveRecord::Migration[7.0]
  def change
    remove_column :decidim_initiatives, :hashtag, :string
  end
end

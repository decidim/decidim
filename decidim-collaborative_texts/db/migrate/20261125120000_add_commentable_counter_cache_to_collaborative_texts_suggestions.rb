# frozen_string_literal: true

class AddCommentableCounterCacheToCollaborativeTextsSuggestions < ActiveRecord::Migration[8.0]
  def change
    add_column :decidim_collaborative_texts_suggestions, :comments_count, :integer, null: false, default: 0
    add_index :decidim_collaborative_texts_suggestions, :comments_count
  end
end

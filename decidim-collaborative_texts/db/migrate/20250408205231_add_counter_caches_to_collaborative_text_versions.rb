# frozen_string_literal: true

class AddCounterCachesToCollaborativeTextVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_collaborative_texts_versions, :suggestions_count, :integer, null: false, default: 0
    add_index :decidim_collaborative_texts_versions, :suggestions_count, name: "idx_decidim_collaborative_texts_versions_suggestions_count"
  end
end

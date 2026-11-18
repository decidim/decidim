# frozen_string_literal: true

class CreateCollaborativeTextsSuggestionVotes < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_collaborative_texts_suggestion_votes do |t|
      t.references :suggestion, null: false, foreign_key: { to_table: :decidim_collaborative_texts_suggestions, on_delete: :cascade },
                                index: { name: "idx_ct_suggestion_votes_on_suggestion" }
      t.references :decidim_author, polymorphic: true, null: false, index: { name: "idx_ct_suggestion_votes_on_author" }
      t.integer :weight, null: false
      t.timestamps
    end

    add_index :decidim_collaborative_texts_suggestion_votes,
              [:suggestion_id, :decidim_author_id, :decidim_author_type],
              unique: true,
              name: "idx_ct_suggestion_votes_unique"
  end
end

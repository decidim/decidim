# frozen_string_literal: true

class MakeAuthorPolymorphicForCommentVotes < ActiveRecord::Migration[5.2]
  class CommentVote < ApplicationRecord
    self.table_name = :decidim_comments_comment_votes
  end

  def change
    add_column :decidim_comments_comment_votes, :decidim_author_type, :string

    reversible do |direction|
      direction.up do
        execute <<~SQL.squish
          UPDATE decidim_comments_comment_votes
          SET decidim_author_type = 'Decidim::UserBaseEntity'
        SQL
      end
    end

    add_index :decidim_comments_comment_votes,
              [:decidim_author_id, :decidim_author_type],
              name: "index_decidim_comments_comment_votes_on_decidim_author"

    change_column_null :decidim_comments_comment_votes, :decidim_author_id, false
    change_column_null :decidim_comments_comment_votes, :decidim_author_type, false
    CommentVote.reset_column_information
  end
end

# frozen_string_literal: true
module Decidim
  module Comments
    # A comment can include user votes. A user should be able to upVote, votes with
    # weight 1 and downVote, votes with weight -1.
    class CommentVote < ApplicationRecord
      belongs_to :comment, foreign_key: "decidim_comment_id", class_name: Comment
      belongs_to :author, foreign_key: "decidim_author_id", class_name: Decidim::User
      
      validates :comment, uniqueness: { scope: :author }
    end
  end
end

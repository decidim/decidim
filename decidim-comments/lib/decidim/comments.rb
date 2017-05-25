# frozen_string_literal: true

require "decidim/comments/admin"
require "decidim/comments/engine"
require "decidim/comments/admin_engine"

module Decidim
  # This module contains all the logic related to the comments feature.
  # It exposes a single entry point as a rails helper method to render
  # a React component which handle all the comments render and logic.
  module Comments
    autoload :CommentsHelper, "decidim/comments/comments_helper"
    autoload :AddCommentType, "decidim/comments/api/add_comment_type"
    autoload :CommentMutationType, "decidim/comments/api/comment_mutation_type"
    autoload :CommentType, "decidim/comments/api/comment_type"
    autoload :Commentable, "decidim/comments/commentable"
  end
end

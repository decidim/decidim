# frozen_string_literal: true

module Decidim
  module Comments
    autoload :CommentableInterface, "decidim/api/commentable_interface"
    autoload :AddCommentType, "decidim/api/add_comment_type"
    autoload :CommentMutationType, "decidim/api/comment_mutation_type"
    autoload :CommentType, "decidim/api/comment_type"
  end
end

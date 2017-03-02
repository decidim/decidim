# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Comments
    # Shared behaviour for commentable models.
    module Commentable
      extend ActiveSupport::Concern

      included do
        has_many :comments, as: :commentable, foreign_key: "decidim_commentable_id", foreign_type: "decidim_commentable_type", class_name: "Decidim::Comments::Comment"

        # Public: Wether the object's comments are visible or not.
        def commentable?
          true
        end

        # Public: Wether the object can have new comments or not.
        def accepts_new_comments?
          true
        end

        # Public: Wether the object's comments can have alignment or not. It enables the
        # alignment selector in the add new comment form.
        def comments_have_alignment?
          false
        end

        # Public: Wether the object's comments can have have votes or not. It enables the
        # upvote and downvote buttons for comments.
        def comments_have_votes?
          false
        end

        # Public: Identifies the commentable type in the API.
        def commentable_type
          self.class.name
        end
      end
    end
  end
end

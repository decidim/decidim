# frozen_string_literal: true

require "decidim/comments/admin"
require "decidim/comments/api"
require "decidim/comments/engine"
require "decidim/comments/admin_engine"

module Decidim
  # This module contains all the logic related to the comments component.
  # It exposes a single entry point as a rails helper method to render
  # a React component which handle all the comments render and logic.
  module Comments
    autoload :CommentsHelper, "decidim/comments/comments_helper"
    autoload :Commentable, "decidim/comments/commentable"
    autoload :CommentSerializer, "decidim/comments/comment_serializer"
    autoload :CommentVoteSerializer, "decidim/comments/comment_vote_serializer"
    autoload :Export, "decidim/comments/export"
    autoload :Markdown, "decidim/comments/markdown"

    def self.data_portable_entities
      ["Decidim::Comments::Comment", "Decidim::Comments::CommentVote"]
    end

    def self.newsletter_participant_entities
      ["Decidim::Comments::Comment"]
    end
  end
end

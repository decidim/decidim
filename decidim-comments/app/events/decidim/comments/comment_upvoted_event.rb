# frozen_string_literal: true

module Decidim
  module Comments
    class CommentUpvotedEvent < Decidim::Comments::CommentVotedEvent
      def perform_translation?
        false
      end
    end
  end
end

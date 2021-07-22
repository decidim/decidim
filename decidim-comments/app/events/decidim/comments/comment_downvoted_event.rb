# frozen_string_literal: true

module Decidim
  module Comments
    class CommentDownvotedEvent < Decidim::Comments::CommentVotedEvent
      def perform_translation?
        false
      end
    end
  end
end

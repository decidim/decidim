# frozen_string_literal: true

module Decidim
  module Comments
    # Controller that manages the comment votes.
    #
    class CommentsVotesController < Decidim::Comments::ApplicationController
      def create
        # TODO: Check permissions
        # TODO: Update the vote on the comment
      end
    end
  end
end

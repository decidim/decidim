# frozen_string_literal: true

module Decidim
  module Elections
    # Custom helpers for the voting booth views.
    #
    module VotesHelper
      def more_information?(answer)
        answer.description || answer.proposals.any? || answer.photos.any?
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Proposals
    #
    # Decorator for votes
    #
    class VotePresenter < SimpleDelegator
      def created_at_date
        __getobj__.created_at.try(:strftime, "%Y-%m-%d")
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Elections
    # This class holds a form to vote for an election
    class VotingForm < Decidim::Form
      include TranslatableAttributes

      def election
        @election ||= context[:election]
      end

      delegate :questions, to: :election

      def total_steps
        questions.count
      end
    end
  end
end

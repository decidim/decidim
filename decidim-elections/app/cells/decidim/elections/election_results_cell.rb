# frozen_string_literal: true

module Decidim
  module Elections
    # This cell renders the results
    # for a given instance of an Election
    class ElectionResultsCell < Decidim::ViewModel
      def show
        render if model.results_published?
      end

      private

      def votes_percentage_for(answer)
        answer.question.votes_percentage(answer.votes_count)
      end
    end
  end
end

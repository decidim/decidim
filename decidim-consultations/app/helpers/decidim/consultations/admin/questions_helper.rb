# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Helper for questions controller
      module QuestionsHelper
        def question_example_slug
          "question-#{Time.now.utc.year}-#{Time.now.utc.month}-1"
        end
      end
    end
  end
end

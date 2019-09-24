# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Helper for questions controller
      module QuestionsHelper
        include Decidim::TranslationsHelper

        Option = Struct.new(:id, :title)

        def question_example_slug
          "question-#{Time.now.utc.year}-#{Time.now.utc.month}-1"
        end

        def question_response_groups(question = current_question)
          [Option.new("", "-")] +
            question.response_groups.map do |group|
              Option.new(group.id, translated_attribute(group.title))
            end
        end
      end
    end
  end
end

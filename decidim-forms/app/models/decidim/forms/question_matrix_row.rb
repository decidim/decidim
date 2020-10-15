# frozen_string_literal: true

module Decidim
  module Forms
    # The data store for a QuestionMatrix in the Decidim::Forms component.
    class QuestionMatrixRow < Forms::ApplicationRecord
      include Decidim::TranslatableResource

      translatable_fields :body
      belongs_to :question, class_name: "Question", foreign_key: "decidim_question_id"

      delegate :answer_options, :mandatory, :max_choices, to: :question
    end
  end
end

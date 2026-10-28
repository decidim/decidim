# frozen_string_literal: true

module Decidim
  module Forms
    # The data store for a QuestionMatrix in the Decidim::Forms component.
    class QuestionMatrixRow < Forms::ApplicationRecord
      include Decidim::TranslatableResource

      translatable_fields :body
      belongs_to :question, class_name: "Question", foreign_key: "decidim_question_id", counter_cache: :matrix_rows_count, inverse_of: :matrix_rows

      has_many :choices,
               class_name: "ResponseChoice",
               foreign_key: "decidim_question_matrix_row_id",
               dependent: :destroy,
               inverse_of: :matrix_row

      delegate :response_options, :mandatory, :max_choices, to: :question

      scope :by_position, -> { order(:position) }
      default_scope { by_position }
    end
  end
end

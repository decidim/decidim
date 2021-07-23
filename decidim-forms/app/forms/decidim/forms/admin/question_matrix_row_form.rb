# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # This class holds a Form to update questionnaire question matrixes from Decidim's admin panel.
      class QuestionMatrixRowForm < Decidim::Form
        include TranslatableAttributes

        attribute :position, Integer
        attribute :deleted, Boolean, default: false

        translatable_attribute :body, String

        validates :position, numericality: { greater_than_or_equal_to: 0 }, if: -> { position.present? }
        validates :body, translatable_presence: true, unless: :deleted

        def to_param
          return id if id.present?

          "questionnaire-question-matrix-row-id"
        end
      end
    end
  end
end

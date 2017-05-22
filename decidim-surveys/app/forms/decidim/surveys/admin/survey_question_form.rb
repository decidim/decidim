# frozen_string_literal: true
module Decidim
  module Surveys
    module Admin
      # This class holds a Form to update survey questions from Decidim's admin panel.
      class SurveyQuestionForm < Decidim::Form
        include TranslatableAttributes

        attribute :id, String
        attribute :position, Integer
        attribute :deleted, Boolean, default: false

        translatable_attribute :body, String

        validates :position, numericality: { greater_than_or_equal_to: 0 }
      end
    end
  end
end

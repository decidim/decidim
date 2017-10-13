# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # This class holds a Form to update surveys from Decidim's admin panel.
      class SurveyForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        translatable_attribute :tos, String
        attribute :published_at, DateTime

        attribute :questions, Array[SurveyQuestionForm]

        validates :title, :tos, translatable_presence: true
      end
    end
  end
end

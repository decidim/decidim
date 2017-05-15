# frozen_string_literal: true
module Decidim
  module Surveys
    module Admin
      # This class holds a Form to update surveys from Decidim's admin panel.
      class SurveyForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        translatable_attribute :toc, String

        attribute :questions, Array[SurveyQuestionForm]
      end
    end
  end
end

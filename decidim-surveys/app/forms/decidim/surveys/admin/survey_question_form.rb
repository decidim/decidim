# frozen_string_literal: true
module Decidim
  module Surveys
    module Admin
      # This class holds a Form to update surveys from Decidim's admin panel.
      class SurveyQuestionForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :body, String
      end
    end
  end
end

# frozen_string_literal: true
module Decidim
  module Surveys
    module Admin
      # This class holds a Form to update survey questions from Decidim's admin panel.
      class SurveyQuestionForm < Decidim::Form
        include TranslatableAttributes

        attribute :id, String
        attribute :deleted, Boolean, default: false
        translatable_attribute :body, String
      end
    end
  end
end

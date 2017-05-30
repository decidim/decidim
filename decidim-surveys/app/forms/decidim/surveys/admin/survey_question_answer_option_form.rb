# frozen_string_literal: true
module Decidim
  module Surveys
    module Admin
      # This class holds a Form to update survey question answer options
      class SurveyQuestionAnswerOptionForm < Decidim::Form
        include TranslatableAttributes

        attribute :body, String
        translatable_attribute :body, String
      end
    end
  end
end

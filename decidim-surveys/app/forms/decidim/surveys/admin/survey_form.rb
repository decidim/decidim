# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      class SurveyForm < Decidim::Forms::Admin::QuestionnaireForm
        include TranslatableAttributes

        validates :title, translatable_presence: true
        validates :tos, presence: true
      end
    end
  end
end

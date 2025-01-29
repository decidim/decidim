# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      class SurveyForm < Decidim::Forms::Admin::QuestionnaireForm
        translatable_attribute :announcement, String

        attribute :allow_answers, Boolean
        attribute :allow_unregistered, Boolean
        attribute :clean_after_publish, Boolean
        attribute :starts_at, Decidim::Attributes::TimeWithZone
        attribute :ends_at, Decidim::Attributes::TimeWithZone
      end
    end
  end
end

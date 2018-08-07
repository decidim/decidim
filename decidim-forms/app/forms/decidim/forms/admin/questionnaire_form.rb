# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # This class holds a Form to update questionnaires from Decidim's admin panel.
      class QuestionnaireForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        translatable_attribute :tos, String

        attribute :published_at, Decidim::Attributes::TimeWithZone
        attribute :questions, Array[QuestionForm]

        validates :title, :tos, translatable_presence: true

        def map_model(model)
          self.questions = model.questions.map do |question|
            QuestionForm.from_model(question)
          end
        end
      end
    end
  end
end

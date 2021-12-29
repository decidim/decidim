# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to update questionnaires from Decidim's admin panel.
      class QuestionnaireForm < Decidim::Form
        attribute :published_at, Decidim::Attributes::TimeWithZone
        attribute :questions, Array[Decidim::Meetings::Admin::QuestionForm]

        def map_model(model)
          self.questions = model.questions.map do |question|
            Decidim::Meetings::Admin::QuestionForm.from_model(question)
          end
        end
      end
    end
  end
end

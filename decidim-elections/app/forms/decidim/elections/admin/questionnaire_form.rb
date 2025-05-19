# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class QuestionnaireForm < Decidim::Form
        attribute :questions, Array[Decidim::Elections::Admin::QuestionForm]

        validate :at_least_one_question

        def map_model(model)
          self.questions = model.questions.map do |question|
            Decidim::Elections::Admin::QuestionForm.from_model(question)
          end
        end

        private

        def at_least_one_question
          errors.add(:base, I18n.t("decidim.elections.admin.questionnaire_form.errors.at_least_one_question")) if questions.reject(&:deleted).blank?
        end
      end
    end
  end
end

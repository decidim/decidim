# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class QuestionsForm < Decidim::Form
        attribute :questions, Array[Decidim::Elections::Admin::QuestionForm]

        validate :at_least_one_question

        def map_model(model)
          self.questions = model.questions
                                .includes(:response_options)
                                .order(:position)
                                .map do |question|
            Decidim::Elections::Admin::QuestionForm.from_model(question)
          end
        end

        private

        def at_least_one_question
          errors.add(:base, I18n.t("decidim.elections.admin.questions.form.errors.at_least_one_question")) if questions.reject(&:deleted).blank?
        end
      end
    end
  end
end

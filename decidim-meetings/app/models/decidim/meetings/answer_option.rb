# frozen_string_literal: true

module Decidim
  module Meetings
    class AnswerOption < Meetings::ApplicationRecord
      include Decidim::TranslatableResource

      default_scope { order(arel_table[:id].asc) }

      translatable_fields :body

      belongs_to :question, class_name: "Decidim::Meetings::Question", foreign_key: "decidim_question_id"
      has_many :choices,
               class_name: "AnswerChoice",
               foreign_key: "decidim_answer_option_id",
               dependent: :destroy,
               inverse_of: :answer_option

      def translated_body
        Decidim::Forms::AnswerOptionPresenter.new(self).translated_body
      end
    end
  end
end

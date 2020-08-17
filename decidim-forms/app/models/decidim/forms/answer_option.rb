# frozen_string_literal: true

module Decidim
  module Forms
    class AnswerOption < Forms::ApplicationRecord
      include Decidim::TranslatableResource

      default_scope { order(arel_table[:id].asc) }

      translatable_fields :body

      belongs_to :question, class_name: "Question", foreign_key: "decidim_question_id"

      has_many :display_conditions,
               class_name: "DisplayCondition",
               foreign_key: "decidim_answer_option_id",
               dependent: :nullify,
               inverse_of: :answer_option

      def translated_body
        Decidim::Forms::AnswerOptionPresenter.new(self).translated_body
      end
    end
  end
end

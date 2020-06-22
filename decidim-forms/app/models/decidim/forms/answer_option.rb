# frozen_string_literal: true

module Decidim
  module Forms
    class AnswerOption < Forms::ApplicationRecord
      include Decidim::TranslatableResource

      default_scope { order(arel_table[:id].asc) }

      translatable_fields :body

      belongs_to :question, class_name: "Question", foreign_key: "decidim_question_id"
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Forms
    class ResponseOption < Forms::ApplicationRecord
      include Decidim::TranslatableResource

      default_scope { order(arel_table[:id].asc) }

      translatable_fields :body

      belongs_to :question, class_name: "Question", foreign_key: "decidim_question_id", counter_cache: :response_options_count, inverse_of: :response_options

      has_many :display_conditions,
               class_name: "DisplayCondition",
               foreign_key: "decidim_response_option_id",
               dependent: :nullify,
               inverse_of: :response_option

      has_many :choices,
               class_name: "ResponseChoice",
               foreign_key: "decidim_response_option_id",
               dependent: :restrict_with_error,
               inverse_of: :response_option

      # The `restrict_with_error` check reads the loaded target, which can still hold
      # choices that were already removed through the response when a whole question is
      # being destroyed. Reset the target so the check runs against the database instead
      # of loading every stored choice.
      before_destroy :reset_choices, prepend: true

      def translated_body
        Decidim::Forms::ResponseOptionPresenter.new(self).translated_body
      end

      private

      def reset_choices
        choices.reset
      end
    end
  end
end

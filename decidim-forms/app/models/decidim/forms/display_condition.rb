# frozen_string_literal: true

module Decidim
  module Forms
    # The data store for a DisplayCondition in the Decidim::Forms component.
    # A display condition is associated to two questions. :question is the question
    # that we want to display or hide based on some conditions, and :condition_question
    # is the question the responses of which are checked against the conditions.
    # Conditions can be whether the question is responded ("responded") or it is not ("not_responded"),
    # if the selected response option is ("equal") or is not ("not_equal") a given one, or whether
    # the text value of the response matches a string ("match").
    class DisplayCondition < Forms::ApplicationRecord
      enum condition_type: [:responded, :not_responded, :equal, :not_equal, :match], _prefix: true

      # Question which will be displayed or hidden
      belongs_to :question,
                 class_name: "Question",
                 foreign_key: "decidim_question_id",
                 inverse_of: :display_conditions,
                 counter_cache: :display_conditions_count

      # Question the responses of which are checked against conditions
      belongs_to :condition_question,
                 class_name: "Question",
                 foreign_key: "decidim_condition_question_id",
                 inverse_of: :display_conditions_for_other_questions,
                 counter_cache: :display_conditions_for_other_questions_count

      # Response option provided to check for "equal" or "not_equal" (optional)
      belongs_to :response_option, class_name: "ResponseOption", foreign_key: "decidim_response_option_id", optional: true

      def fulfilled?(response_form)
        return response_form.present? if condition_type == "responded"
        return response_form.blank? if condition_type == "not_responded"
        # rest of options require presence
        return if response_form.blank?

        case condition_type
        when "equal"
          response_form.choices.pluck(:response_option_id).include?(response_option.id)
        when "not_equal"
          response_form.choices.pluck(:response_option_id).exclude?(response_option.id)
        when "match"
          condition_value.values.compact_blank.any? { |value| response_form_matches?(response_form, value) }
        end
      end

      def to_html_data
        {
          id:,
          type: condition_type,
          condition: decidim_condition_question_id,
          option: decidim_response_option_id,
          mandatory:,
          value: condition_value&.dig(I18n.locale.to_s)
        }.compact
      end

      private

      def response_form_matches?(response_form, value)
        search = Regexp.new(value, Regexp::IGNORECASE)
        if response_form.body
          response_form.body.match?(search)
        else
          response_form.choices.any? do |choice_value|
            choice_value.body&.match?(search) || choice_value.custom_body&.match?(search)
          end
        end
      end
    end
  end
end

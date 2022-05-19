# frozen_string_literal: true

module Decidim
  module Forms
    # The data store for a DisplayCondition in the Decidim::Forms component.
    # A display condition is associated to two questions. :question is the question
    # that we want to display or hide based on some conditions, and :condition_question
    # is the question the answers of which are checked against the conditions.
    # Conditions can be whether the question is answered ("answered") or it is not ("not_answered"),
    # if the selected answer option is ("equal") or is not ("not_equal") a given one, or whethe
    # the text value of the answer matches a string ("match").
    class DisplayCondition < Forms::ApplicationRecord
      enum condition_type: [:answered, :not_answered, :equal, :not_equal, :match], _prefix: true

      # Question which will be displayed or hidden
      belongs_to :question, class_name: "Question", foreign_key: "decidim_question_id", inverse_of: :display_conditions

      # Question the answers of which are checked against conditions
      belongs_to :condition_question, class_name: "Question", foreign_key: "decidim_condition_question_id", inverse_of: :display_conditions_for_other_questions

      # Answer option provided to check for "equal" or "not_equal" (optional)
      belongs_to :answer_option, class_name: "AnswerOption", foreign_key: "decidim_answer_option_id", optional: true

      def fulfilled?(answer_form)
        return answer_form.present? if condition_type == "answered"
        return answer_form.blank? if condition_type == "not_answered"
        # rest of options require presence
        return if answer_form.blank?

        case condition_type
        when "equal"
          answer_form.choices.pluck(:answer_option_id).include?(answer_option.id)
        when "not_equal"
          answer_form.choices.pluck(:answer_option_id).exclude?(answer_option.id)
        when "match"
          condition_value.values.compact_blank.any? { |value| answer_form_matches?(answer_form, value) }
        end
      end

      def to_html_data
        {
          id: id,
          type: condition_type,
          condition: decidim_condition_question_id,
          option: decidim_answer_option_id,
          mandatory: mandatory,
          value: condition_value&.dig(I18n.locale.to_s)
        }.compact
      end

      private

      def answer_form_matches?(answer_form, value)
        search = Regexp.new(value, Regexp::IGNORECASE)
        if answer_form.body
          answer_form.body.match?(search)
        else
          answer_form.choices.any? do |choice_value|
            choice_value.body&.match?(search) || choice_value.custom_body&.match?(search)
          end
        end
      end
    end
  end
end

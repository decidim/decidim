# frozen_string_literal: true

module Decidim
  module Forms
    # This class holds a Form to save the questionnaire responses from Decidim's public page
    class ResponseForm < Decidim::Form
      include Decidim::TranslationsHelper
      include Decidim::AttachmentAttributes

      attribute :question_id, String
      attribute :body, String
      attribute :choices, Array[ResponseChoiceForm]
      attribute :matrix_choices, Array[ResponseChoiceForm]

      attachments_attribute :attachments

      validates :body, presence: true, if: :mandatory_body?
      validates :selected_choices, presence: true, if: :mandatory_choices?

      validate :max_choices, if: -> { question.max_choices }
      validate :all_choices, if: :sorting?
      validate :min_choices, if: -> { question.matrix? && question.mandatory? }
      validate :attachments_present, if: -> { question.question_type == "files" && question.mandatory? }
      validate :max_characters, if: -> { question.max_characters.positive? }

      delegate :mandatory_body?, :mandatory_choices?, :matrix?, to: :question

      attr_writer :question

      def question
        @question ||= Decidim::Forms::Question.find(question_id)
      end

      def label
        base = translated_attribute(question.body)
        base += " #{mandatory_label}" if question.mandatory?
        base += " (#{max_choices_label})" if question.max_choices
        base
      end

      # Public: Map the correct fields.
      #
      # Returns nothing.
      def map_model(model)
        self.question_id = model.decidim_question_id
        self.question = model.question
        self.body = model.text_value
        self.attachments = model.attachments
        self.choices = model.selections.map { |selection| choice_form_for(selection) }
      end

      # Public: the response in the stored value format: a String for text questions, choice objects with
      # "option" and "text" (one, an Array, or a Hash keyed by matrix row id), nil when nothing was answered.
      # Files are stored by the command once their attachments exist.
      def value
        case question.question_type
        when "short_response", "long_response" then body.presence
        when "single_option" then choice_value_for(selected_choices.first)
        when "multiple_option", "sorting" then selected_choices.map { |choice| choice_value_for(choice) }.presence
        when "matrix_single" then matrix_value { |choices| choice_value_for(choices.first) }
        when "matrix_multiple" then matrix_value { |choices| choices.map { |choice| choice_value_for(choice) } }
        end
      end

      def selected_choices
        choices.select(&:body)
      end

      def custom_choices
        choices.select(&:custom_body)
      end

      def display_conditions_fulfilled?
        return optional_conditions_fulfilled? unless question.display_conditions.where(mandatory: true).any?

        mandatory_conditions_fulfilled?
      end

      def mandatory_conditions_fulfilled?
        question.display_conditions.where(mandatory: true).all? do |condition|
          response = context.responses&.find { |r| r.question_id&.to_i == condition.condition_question.id }
          condition.fulfilled?(response)
        end
      end

      def optional_conditions_fulfilled?
        return true unless question.display_conditions.where(mandatory: false).any?

        question.display_conditions.where(mandatory: false).any? do |condition|
          response = context.responses&.find { |r| r.question_id&.to_i == condition.condition_question.id }
          condition.fulfilled?(response)
        end
      end

      def has_attachments?
        question.has_attachments? && errors[:add_attachments].empty? && add_attachments.present?
      end

      def has_error_in_attachments?
        errors[:add_attachments].present?
      end

      def sorting?
        question.question_type == "sorting"
      end

      private

      def mandatory_body?
        question.mandatory_body? if display_conditions_fulfilled?
      end

      def mandatory_choices?
        question.mandatory_choices? if display_conditions_fulfilled?
      end

      def grouped_choices
        selected_choices.group_by(&:matrix_row_id).values
      end

      def max_choices
        if matrix?
          errors.add(:choices, :too_many, count: question.max_choices) if grouped_choices.any? { |choices| choices.count > question.max_choices }
        elsif selected_choices.size > question.max_choices
          errors.add(:choices, :too_many, count: question.max_choices)
        end
      end

      def max_characters
        if body.present?
          errors.add(:body, :too_long) if body.size > question.max_characters
        elsif custom_choices.any?
          custom_choices.each do |choice|
            errors.add(:body, :too_long) if choice.custom_body.size > question.max_characters
          end
        end
      end

      def min_choices
        errors.add(:choices, :missing) if grouped_choices.count != question.matrix_rows.count
      end

      def all_choices
        errors.add(:choices, :missing) if selected_choices.size != question.number_of_options
      end

      def mandatory_label
        "*"
      end

      def max_choices_label
        I18n.t("questionnaires.question.max_choices", scope: "decidim.forms", n: question.max_choices)
      end

      def attachments_present
        errors.add(:add_attachments, :blank) if add_attachments.empty? && errors[:add_attachments].empty?
      end

      def choice_value_for(choice)
        return unless choice

        { "option" => choice.response_option_id, "text" => choice.custom_body.presence }.compact
      end

      def matrix_value
        selected_choices.select(&:matrix_row_id).group_by { |choice| choice.matrix_row_id.to_s }.transform_values { |choices| yield(choices) }.presence
      end

      def choice_form_for(selection)
        option = question.response_options.find { |candidate| candidate.id == selection["option"] }
        ResponseChoiceForm.new(
          response_option_id: selection["option"],
          matrix_row_id: selection["row"],
          custom_body: selection["text"],
          body: option ? option.translated_body : selection["label"].to_s
        )
      end
    end
  end
end

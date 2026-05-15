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

      attachments_attribute :documents

      validates :body, presence: true, if: :mandatory_body?
      validates :selected_choices, presence: true, if: :mandatory_choices?

      validate :max_choices, if: -> { question.max_choices }
      validate :all_choices, if: :sorting?
      validate :min_choices, if: -> { question.matrix? && question.mandatory? }
      validate :documents_present, if: -> { question.question_type == "files" && question.mandatory? }
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
        self.documents = model.attachments

        self.choices = model.choices.map do |choice|
          ResponseChoiceForm.from_model(choice)
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
        question.has_attachments? && errors[:add_documents].empty? && add_documents.present?
      end

      def has_error_in_attachments?
        errors[:add_documents].present?
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

      def documents_present
        errors.add(:add_documents, :blank) if add_documents.empty? && errors[:add_documents].empty?
      end
    end
  end
end

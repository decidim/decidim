# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :questionnaire, class: "Decidim::Forms::Questionnaire" do
    title { generate_localized_title }
    description do
      Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        generate_localized_title
      end
    end
    tos { generate_localized_title }
    questionnaire_for { build(:participatory_process) }

    trait :with_questions do
      questions do
        qs = %w(short_answer long_answer).collect do |text_question_type|
          build(:questionnaire_question, question_type: text_question_type)
        end
        qs << build(:questionnaire_question, :with_answer_options, question_type: :single_option)
        qs
      end
    end
  end

  factory :questionnaire_question, class: "Decidim::Forms::Question" do
    transient do
      options { [] }
      rows { [] }
    end

    body { generate_localized_title }
    description do
      Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        generate_localized_title
      end
    end
    mandatory { false }
    position { 0 }
    question_type { Decidim::Forms::Question::TYPES.first }
    questionnaire

    before(:create) do |question, evaluator|
      if question.answer_options.empty?
        evaluator.options.each do |option|
          question.answer_options.build(
            body: option["body"],
            free_text: option["free_text"]
          )
        end
      end

      if question.matrix_rows.empty?
        evaluator.rows.each do |row|
          question.matrix_rows.build(
            body: row["body"]
          )
        end
      end
    end

    trait :with_answer_options do
      answer_options do
        Array.new(3).collect { build(:answer_option) }
      end
    end

    trait :conditioned do
      display_conditions do
        Array.new(3).collect { build(:display_condition) }
      end
    end

    trait :separator do
      question_type { :separator }
    end
  end

  factory :answer, class: "Decidim::Forms::Answer" do
    body { "hola" }
    questionnaire
    question { create(:questionnaire_question, questionnaire: questionnaire) }
    user { create(:user, organization: questionnaire.questionnaire_for.organization) }
  end

  factory :answer_option, class: "Decidim::Forms::AnswerOption" do
    question { create(:questionnaire_question) }
    body { generate_localized_title }
    free_text { false }
  end

  factory :answer_choice, class: "Decidim::Forms::AnswerChoice" do
    answer
    answer_option { create(:answer_option, question: answer.question) }
    matrix_row { create(:question_matrix_row, question: answer.question) }
  end

  factory :question_matrix_row, class: "Decidim::Forms::QuestionMatrixRow" do
    question { create(:questionnaire_question) }
    body { generate_localized_title }
    position { 0 }
  end

  factory :display_condition, class: "Decidim::Forms::DisplayCondition" do
    condition_question { create(:questionnaire_question) }
    question { create(:questionnaire_question, position: 1) }
    condition_type { :answered }
    mandatory { true }

    trait :equal do
      condition_type { :equal }
      answer_option { create(:answer_option, question: condition_question) }
    end

    trait :match do
      condition_type { :match }
      condition_value { generate_localized_title }
    end
  end
end

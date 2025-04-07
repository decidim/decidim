# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :questionnaire, class: "Decidim::Forms::Questionnaire" do
    transient do
      skip_injection { false }
    end
    title { generate_localized_title(:questionnaire_title, skip_injection:) }
    description { generate_localized_description(:questionnaire_description, skip_injection:) }
    tos { generate_localized_title(:questionnaire_tos, skip_injection:) }
    questionnaire_for { build(:participatory_process, skip_injection:) }
    salt { SecureRandom.hex(32) }

    trait :with_questions do
      questions do
        position = 0
        qs = %w(short_response long_response).collect do |text_question_type|
          q = build(:questionnaire_question, question_type: text_question_type, position:, skip_injection:)
          position += 1
          q
        end
        qs << build(:questionnaire_question, :with_response_options, question_type: :single_option, position:, skip_injection:)
        qs
      end
    end

    trait :with_all_questions do
      after(:build) do |questionnaire, evaluator|
        position = 0
        %w(short_response long_response).collect do |text_question_type|
          q = create(:questionnaire_question,
                     question_type: text_question_type,
                     position:,
                     questionnaire:,
                     skip_injection: evaluator.skip_injection)
          position += 1
          questionnaire.questions << q
        end

        %w(single_option multiple_option).each do |option_question_type|
          q = create(:questionnaire_question, :with_response_options,
                     question_type: option_question_type,
                     position:,
                     questionnaire:,
                     skip_injection: evaluator.skip_injection)
          q.display_conditions.build(
            condition_question: questionnaire.questions[q.position - 1],
            question: q,
            condition_type: :responded,
            mandatory: true
          )
          questionnaire.questions << q
          position += 1
        end

        %w(matrix_single matrix_multiple).collect do |matrix_question_type|
          q = build(:questionnaire_question, :with_response_options,
                    question_type: matrix_question_type,
                    position:,
                    body: generate_localized_title,
                    questionnaire:,
                    skip_injection: evaluator.skip_injection)
          q.display_conditions.build(
            condition_question: questionnaire.questions[q.position - 1],
            question: q,
            condition_type: :responded,
            mandatory: true
          )
          questionnaire.questions << q
          position += 1
        end
      end
    end

    trait :empty do
      title { {} }
      description { {} }
      tos { {} }
    end
  end

  factory :questionnaire_question, class: "Decidim::Forms::Question" do
    transient do
      skip_injection { false }
      options { [] }
      rows { [] }
    end

    body { generate_localized_title(:questionnaire_question_body, skip_injection:) }
    description { generate_localized_description(:questionnaire_question_description, skip_injection:) }
    mandatory { false }
    position { 0 }
    question_type { Decidim::Forms::Question::TYPES.first }
    questionnaire

    before(:create) do |question, evaluator|
      if question.response_options.empty?
        evaluator.options.each do |option|
          question.response_options.build(
            body: option["body"],
            free_text: option["free_text"]
          )
        end
      end

      if question.matrix_rows.empty?
        evaluator.rows.each_with_index do |row, idx|
          question.matrix_rows.build(
            body: row["body"],
            position: idx
          )
        end
      end
    end

    trait :with_response_options do
      response_options do
        Array.new(3).collect { build(:response_option, skip_injection:) }
      end
    end

    trait :conditioned do
      display_conditions do
        Array.new(3).collect { build(:display_condition, skip_injection:) }
      end
    end

    trait :separator do
      question_type { :separator }
    end

    trait :title_and_description do
      question_type { :title_and_description }
    end
  end

  factory :response, class: "Decidim::Forms::Response" do
    transient do
      skip_injection { false }
    end
    body { "hola" }
    questionnaire
    question { create(:questionnaire_question, questionnaire:, skip_injection:) }
    user { create(:user, organization: questionnaire.questionnaire_for.organization, skip_injection:) }
    session_token { Digest::SHA256.hexdigest(user.id.to_s) }

    trait :with_attachments do
      after(:create) do |response, evaluator|
        create(:attachment, :with_image, attached_to: response, skip_injection: evaluator.skip_injection)
        create(:attachment, :with_pdf, attached_to: response, skip_injection: evaluator.skip_injection)
      end
    end
  end

  factory :response_option, class: "Decidim::Forms::ResponseOption" do
    transient do
      skip_injection { false }
    end
    question { create(:questionnaire_question, skip_injection:) }
    body { generate_localized_title }
    free_text { false }

    trait :free_text_enabled do
      free_text { true }
    end

    trait :free_text_disabled do
      free_text { false }
    end
  end

  factory :response_choice, class: "Decidim::Forms::ResponseChoice" do
    transient do
      skip_injection { false }
    end
    response
    response_option { create(:response_option, question: response.question, skip_injection:) }
    matrix_row { create(:question_matrix_row, question: response.question, skip_injection:) }
  end

  factory :question_matrix_row, class: "Decidim::Forms::QuestionMatrixRow" do
    transient do
      skip_injection { false }
    end
    question { create(:questionnaire_question, skip_injection:) }
    body { generate_localized_title }
    position { 0 }
  end

  factory :display_condition, class: "Decidim::Forms::DisplayCondition" do
    transient do
      skip_injection { false }
    end
    condition_question { create(:questionnaire_question, skip_injection:) }
    question { create(:questionnaire_question, position: 1, skip_injection:) }
    condition_type { :responded }
    mandatory { true }

    trait :equal do
      condition_type { :equal }
      response_option { create(:response_option, question: condition_question, skip_injection:) }
    end

    trait :match do
      condition_type { :match }
      condition_value { generate_localized_title(:condition_value, skip_injection:) }
    end
  end
end

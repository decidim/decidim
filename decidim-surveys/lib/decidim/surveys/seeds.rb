# frozen_string_literal: true

require "decidim/components/namer"

module Decidim
  module Surveys
    class Seeds
      attr_reader :participatory_space

      def initialize(participatory_space:)
        @participatory_space = participatory_space
      end

      def call
        admin_user = Decidim::User.find_by(
          organization: participatory_space.organization,
          email: "admin@example.org"
        )

        params = {
          name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :surveys).i18n_name,
          manifest_name: :surveys,
          published_at: Time.current,
          participatory_space:
        }

        component = Decidim.traceability.perform_action!(
          "publish",
          Decidim::Component,
          admin_user,
          visibility: "all"
        ) do
          Decidim::Component.create!(params)
        end

        questionnaire = Decidim::Forms::Questionnaire.new(
          title: Decidim::Faker::Localized.paragraph,
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          tos: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 2)
          end
        )

        params = {
          component:,
          questionnaire:
        }

        Decidim.traceability.create!(
          Decidim::Surveys::Survey,
          admin_user,
          params,
          visibility: "all"
        )

        %w(short_answer long_answer).each_with_index do |text_question_type, index|
          Decidim::Forms::Question.create!(
            questionnaire:,
            body: Decidim::Faker::Localized.paragraph,
            question_type: text_question_type,
            position: index
          )
        end

        %w(single_option multiple_option).each_with_index do |multiple_choice_question_type, index|
          question = Decidim::Forms::Question.create!(
            questionnaire:,
            body: Decidim::Faker::Localized.paragraph,
            question_type: multiple_choice_question_type,
            position: index + 2
          )

          3.times do
            question.answer_options.create!(body: Decidim::Faker::Localized.sentence)
          end

          question.display_conditions.create!(
            condition_question: questionnaire.questions.find_by(position: question.position - 2),
            question:,
            condition_type: :answered,
            mandatory: true
          )
        end

        %w(matrix_single matrix_multiple).each_with_index do |matrix_question_type, index|
          question = Decidim::Forms::Question.create!(
            questionnaire:,
            body: Decidim::Faker::Localized.paragraph,
            question_type: matrix_question_type,
            position: index
          )

          3.times do |position|
            question.answer_options.create!(body: Decidim::Faker::Localized.sentence)
            question.matrix_rows.create!(body: Decidim::Faker::Localized.sentence, position:)
          end
        end
      end
    end
  end
end

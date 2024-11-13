# frozen_string_literal: true

require "decidim/components/namer"

module Decidim
  module Surveys
    class Seeds < Decidim::Seeds
      attr_reader :participatory_space

      def initialize(participatory_space:)
        @participatory_space = participatory_space
      end

      def call
        component = create_component!

        questionnaire = create_questionnaire!(component:)

        create_questions!(questionnaire:)
      end

      def create_component!
        step_settings = if participatory_space.allows_steps?
                          { participatory_space.active_step.id => { allow_answers: true } }
                        else
                          {}
                        end

        params = {
          name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :surveys).i18n_name,
          manifest_name: :surveys,
          published_at: Time.current,
          participatory_space:,
          step_settings:
        }

        Decidim.traceability.perform_action!(
          "publish",
          Decidim::Component,
          admin_user,
          visibility: "all"
        ) do
          Decidim::Component.create!(params)
        end
      end

      def create_questionnaire!(component:)
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

        questionnaire
      end

      def create_questions!(questionnaire:)
        user = find_or_initialize_user_by(email: "survey-#{questionnaire.id}-#{rand(10_000)}@example.org")
        session_token = Digest::MD5.hexdigest("#{user.id}-#{Rails.application.secret_key_base}")
        ip_hash = Faker::Internet.device_token.slice(0, 24)

        %w(short_answer long_answer files).each_with_index do |text_question_type, index|
          question = Decidim::Forms::Question.create!(
            mandatory: text_question_type == "short_answer",
            questionnaire:,
            body: Decidim::Faker::Localized.paragraph,
            question_type: text_question_type,
            position: index
          )
          next if text_question_type == "files"

          Decidim::Forms::Answer.create!(
            user:,
            questionnaire:,
            question:,
            body: ::Faker::Lorem.paragraph(sentence_count: 1),
            session_token:,
            ip_hash:
          )
        end

        %w(single_option multiple_option sorting).each_with_index do |multiple_choice_question_type, index|
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

          answer = Decidim::Forms::Answer.create!(
            user:,
            questionnaire:,
            question:,
            body: nil,
            session_token:,
            ip_hash:
          )

          answer_option = question.answer_options.sample
          Decidim::Forms::AnswerChoice.create!(
            answer:,
            answer_option:,
            body: answer_option["en"]
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

          answer = Decidim::Forms::Answer.create!(
            user:,
            questionnaire:,
            question:,
            body: nil,
            session_token:,
            ip_hash:
          )

          matrix_row = question.matrix_rows.sample
          answer_option = question.answer_options.sample
          Decidim::Forms::AnswerChoice.create!(
            answer:,
            answer_option:,
            matrix_row:,
            body: answer_option["en"]
          )
        end

        Decidim::Forms::Question.create!(
          questionnaire:,
          body: nil,
          question_type: "separator",
          position: 3
        )
      end
    end
  end
end

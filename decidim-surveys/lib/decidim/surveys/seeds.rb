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

        3.times do
          questionnaire = create_questionnaire!(component:)
          create_questions!(questionnaire:)

          next if questionnaire.questionnaire_for.allow_answers

          rand(200).times { create_answers!(questionnaire:) }
        end
      end

      def create_component!
        params = {
          name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :surveys).i18n_name,
          manifest_name: :surveys,
          published_at: Time.current,
          participatory_space:
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
          questionnaire:,
          allow_answers: [true, false].sample,
          published_at: Time.current
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
        %w(short_answer long_answer files).each_with_index do |text_question_type, index|
          Decidim::Forms::Question.create!(
            mandatory: text_question_type == "short_answer",
            questionnaire:,
            body: Decidim::Faker::Localized.paragraph,
            question_type: text_question_type,
            position: index
          )
          next if text_question_type == "files"
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

          # Files type questions do not support being conditionals for another questions
          files_question = questionnaire.questions.where(question_type: "files")
          possible_condition_questions = questionnaire.questions.excluding(files_question)

          question.display_conditions.create!(
            condition_question: possible_condition_questions.sample,
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

        Decidim::Forms::Question.create!(
          questionnaire:,
          body: nil,
          question_type: "separator",
          position: 3
        )
      end

      def create_answers!(questionnaire:, user: nil)
        user = find_or_initialize_user_by(email: "survey-#{questionnaire.id}-#{rand(1_000_000)}@example.org") if user.nil?

        answer_options = {
          user:,
          questionnaire:,
          session_token: Digest::MD5.hexdigest("#{user.id}-#{Rails.application.secret_key_base}"),
          ip_hash: Faker::Internet.device_token.slice(0, 24)
        }

        questionnaire.questions.each do |question|
          case question.question_type
          when "short_answer", "long_answer"
            create_answer_for_text_question_type!(answer_options.merge({ question: }))
          when "single_option", "multiple_option"
            create_answer_for_multiple_choice_question_type(answer_options.merge({ question: }))
          when "sorting"
            create_answer_for_sorting_question_type(answer_options.merge({ question: }))
          when "matrix_single", "matrix_multiple"
            create_answer_for_matrix_question_type(answer_options.merge({ question: }))
          end
        end
      rescue ActiveRecord::RecordInvalid
        # Silently ignore the error as we do not care if the user already exists
      end

      def create_answer_for_text_question_type!(options)
        Decidim::Forms::Answer.create!(
          **options, body: ::Faker::Lorem.paragraph(sentence_count: 1)
        )
      end

      def create_answer_for_sorting_question_type(options)
        answer = Decidim::Forms::Answer.create!(**options)
        answer_options = options[:question].answer_options
        available_positions = (0..(answer_options.count - 1)).to_a

        answer_options.each do |answer_option|
          position = available_positions.sample
          body = answer_option["en"]

          Decidim::Forms::AnswerChoice.create!(
            answer:,
            answer_option:,
            body:,
            position:
          )
        end
      end

      def create_answer_for_multiple_choice_question_type(options)
        answer = Decidim::Forms::Answer.create!(**options)
        answer_option = options[:question].answer_options.sample
        body = answer_option["en"]

        Decidim::Forms::AnswerChoice.create!(
          answer:,
          answer_option:,
          body:
        )
      end

      def create_answer_for_matrix_question_type(options)
        answer = Decidim::Forms::Answer.create!(**options)
        answer_option = options[:question].answer_options.sample
        matrix_row = options[:question].matrix_rows.sample
        body = answer_option["en"]

        Decidim::Forms::AnswerChoice.create!(
          answer:,
          answer_option:,
          matrix_row:,
          body:
        )
      end
    end
  end
end

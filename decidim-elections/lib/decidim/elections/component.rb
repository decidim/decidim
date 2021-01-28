# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:elections) do |component|
  component.engine = Decidim::Elections::Engine
  component.admin_engine = Decidim::Elections::AdminEngine
  component.icon = "decidim/elections/icon.svg"
  component.stylesheet = "decidim/elections/elections"
  component.permissions_class_name = "Decidim::Elections::Permissions"
  component.query_type = "Decidim::Elections::ElectionsType"

  component.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this component" if Decidim::Elections::Election.where(component: instance).any?
  end

  # These actions permissions can be configured in the admin panel
  component.actions = %w(vote)

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_stat :elections_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, start_at, end_at|
    elections = Decidim::Elections::FilteredElections.for(components, start_at, end_at)
    elections.count
  end

  component.register_resource(:election) do |resource|
    resource.model_class_name = "Decidim::Elections::Election"
    resource.actions = %w(vote)
    resource.card = "decidim/elections/election"
  end

  component.register_resource(:question) do |resource|
    resource.model_class_name = "Decidim::Elections::Question"
  end

  component.register_resource(:answer) do |resource|
    resource.model_class_name = "Decidim::Elections::Answer"
  end

  component.exports :feedback_form_answers do |exports|
    exports.collection do |_component, _user, resource_id|
      Decidim::Forms::QuestionnaireUserAnswers.for(resource_id)
    end

    exports.formats %w(CSV JSON Excel FormPDF)

    exports.serializer Decidim::Forms::UserAnswersSerializer
  end

  component.exports :elections do |exports|
    exports.collection do |component_instance|
      Decidim::Elections::Question.where(election: Decidim::Elections::Election.where(component: component_instance).bb_results_published).collect(&:answers).flatten
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Elections::AnswerSerializer
  end

  component.seeds do |participatory_space|
    admin_user = Decidim::User.find_by(
      organization: participatory_space.organization,
      email: "admin@example.org"
    )

    params = {
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :elections).i18n_name,
      manifest_name: :elections,
      published_at: Time.current,
      participatory_space: participatory_space
    }

    component = Decidim.traceability.perform_action!(
      "publish",
      Decidim::Component,
      admin_user,
      visibility: "all"
    ) do
      Decidim::Component.create!(params)
    end

    # upcoming elections that may be published
    2.times do
      upcoming_election = Decidim.traceability.create!(
        Decidim::Elections::Election,
        admin_user,
        {
          component: component,
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          start_time: 3.weeks.from_now,
          end_time: 3.weeks.from_now + 4.hours,
          published_at: Faker::Boolean.boolean(true_ratio: 0.5) ? 1.week.ago : nil
        },
        visibility: "all"
      )

      rand(1...4).times do
        upcoming_question = Decidim.traceability.create!(
          Decidim::Elections::Question,
          admin_user,
          {
            election: upcoming_election,
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            max_selections: Faker::Number.between(from: 1, to: 3),
            weight: Faker::Number.number(digits: 1),
            random_answers_order: Faker::Boolean.boolean(true_ratio: 0.5),
            min_selections: Faker::Number.between(from: 0, to: 1)
          },
          visibility: "all"
        )

        rand(upcoming_question.max_selections...5).times do
          answer = Decidim.traceability.create!(
            Decidim::Elections::Answer,
            admin_user,
            {
              question: upcoming_question,
              title: Decidim::Faker::Localized.sentence(word_count: 2),
              description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
                Decidim::Faker::Localized.paragraph(sentence_count: 3)
              end,
              weight: Faker::Number.number(digits: 1),
              selected: Faker::Boolean.boolean(true_ratio: 0.2), # false
              votes_count: 0
            },
            visibility: "all"
          )

          Decidim::Attachment.create!(
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.sentence(word_count: 5),
            attached_to: answer,
            file: File.new(File.join(__dir__, "seeds", "city.jpeg")) # Keep after attached_to
          )
        end

        questionnaire = Decidim::Forms::Questionnaire.create!(
          title: Decidim::Faker::Localized.paragraph,
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          tos: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 2)
          end,
          questionnaire_for: upcoming_election
        )

        %w(short_answer long_answer).each do |text_question_type|
          Decidim::Forms::Question.create!(
            questionnaire: questionnaire,
            body: Decidim::Faker::Localized.paragraph,
            question_type: text_question_type
          )
        end

        %w(single_option multiple_option).each do |multiple_choice_question_type|
          question = Decidim::Forms::Question.create!(
            questionnaire: questionnaire,
            body: Decidim::Faker::Localized.paragraph,
            question_type: multiple_choice_question_type
          )

          3.times do
            question.answer_options.create!(body: Decidim::Faker::Localized.sentence)
          end
        end
      end
    end

    # finished elections that may be published, with questionnaire
    2.times do
      finished_election = Decidim.traceability.create!(
        Decidim::Elections::Election,
        admin_user,
        {
          component: component,
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          start_time: 4.weeks.ago,
          end_time: 3.weeks.ago,
          published_at: 4.weeks.ago
        },
        visibility: "all"
      )

      rand(1...4).times do
        finished_question = Decidim.traceability.create!(
          Decidim::Elections::Question,
          admin_user,
          {
            election: finished_election,
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            max_selections: 2,
            weight: Faker::Number.number(digits: 1),
            random_answers_order: Faker::Boolean.boolean(true_ratio: 0.5),
            min_selections: Faker::Number.between(from: 0, to: 1)
          },
          visibility: "all"
        )

        rand(2...5).times do
          answer = Decidim.traceability.create!(
            Decidim::Elections::Answer,
            admin_user,
            {
              question: finished_question,
              title: Decidim::Faker::Localized.sentence(word_count: 2),
              description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
                Decidim::Faker::Localized.paragraph(sentence_count: 3)
              end,
              weight: Faker::Number.number(digits: 1),
              selected: Faker::Boolean.boolean(true_ratio: 0.2), # false
              votes_count: 0
            },
            visibility: "all"
          )

          Decidim::Attachment.create!(
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.sentence(word_count: 5),
            attached_to: answer,
            file: File.new(File.join(__dir__, "seeds", "city.jpeg")) # Keep after attached_to
          )
        end

        questionnaire = Decidim::Forms::Questionnaire.create!(
          title: Decidim::Faker::Localized.paragraph,
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          tos: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 2)
          end,
          questionnaire_for: finished_election
        )

        %w(short_answer long_answer).each do |text_question_type|
          Decidim::Forms::Question.create!(
            questionnaire: questionnaire,
            body: Decidim::Faker::Localized.paragraph,
            question_type: text_question_type
          )
        end

        %w(single_option multiple_option).each do |multiple_choice_question_type|
          question = Decidim::Forms::Question.create!(
            questionnaire: questionnaire,
            body: Decidim::Faker::Localized.paragraph,
            question_type: multiple_choice_question_type
          )

          3.times do
            question.answer_options.create!(body: Decidim::Faker::Localized.sentence)
          end
        end
      end
    end

    # finished, published elections with results and with questionnaire
    2.times do
      election_with_results = Decidim.traceability.create!(
        Decidim::Elections::Election,
        admin_user,
        {
          component: component,
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          start_time: 4.weeks.ago,
          end_time: 3.weeks.ago,
          published_at: 3.weeks.ago,
          bb_status: "results_published"

        },
        visibility: "all"
      )

      rand(1...4).times do
        result_question = Decidim.traceability.create!(
          Decidim::Elections::Question,
          admin_user,
          {
            election: election_with_results,
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            max_selections: 2,
            weight: Faker::Number.number(digits: 1),
            random_answers_order: Faker::Boolean.boolean(true_ratio: 0.5),
            min_selections: Faker::Number.between(from: 0, to: 1)
          },
          visibility: "all"
        )

        rand(2...5).times do
          answer = Decidim.traceability.create!(
            Decidim::Elections::Answer,
            admin_user,
            {
              question: result_question,
              title: Decidim::Faker::Localized.sentence(word_count: 2),
              description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
                Decidim::Faker::Localized.paragraph(sentence_count: 3)
              end,
              weight: Faker::Number.number(digits: 1),
              selected: Faker::Boolean.boolean(true_ratio: 0.5),
              votes_count: Faker::Number.number(digits: 3)
            },
            visibility: "all"
          )

          Decidim::Attachment.create!(
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.sentence(word_count: 5),
            attached_to: answer,
            file: File.new(File.join(__dir__, "seeds", "city.jpeg")) # Keep after attached_to
          )
        end

        questionnaire = Decidim::Forms::Questionnaire.create!(
          title: Decidim::Faker::Localized.paragraph,
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          tos: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 2)
          end,
          questionnaire_for: election_with_results
        )

        %w(short_answer long_answer).each do |text_question_type|
          Decidim::Forms::Question.create!(
            questionnaire: questionnaire,
            body: Decidim::Faker::Localized.paragraph,
            question_type: text_question_type
          )
        end

        %w(single_option multiple_option).each do |multiple_choice_question_type|
          question = Decidim::Forms::Question.create!(
            questionnaire: questionnaire,
            body: Decidim::Faker::Localized.paragraph,
            question_type: multiple_choice_question_type
          )

          3.times do
            question.answer_options.create!(body: Decidim::Faker::Localized.sentence)
          end
        end
      end
    end

    # ongoing election that is published
    ongoing_election = Decidim.traceability.create!(
      Decidim::Elections::Election,
      admin_user,
      {
        component: component,
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(sentence_count: 3)
        end,
        start_time: 2.weeks.ago,
        end_time: 2.weeks.from_now + 4.hours,
        published_at: 3.weeks.ago
      },
      visibility: "all"
    )

    rand(1...4).times do
      ongoing_question = Decidim.traceability.create!(
        Decidim::Elections::Question,
        admin_user,
        {
          election: ongoing_election,
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          max_selections: 2,
          weight: Faker::Number.number(digits: 1),
          random_answers_order: Faker::Boolean.boolean(true_ratio: 0.5),
          min_selections: Faker::Number.between(from: 0, to: 1)
        },
        visibility: "all"
      )

      rand(3...5).times do
        answer = Decidim.traceability.create!(
          Decidim::Elections::Answer,
          admin_user,
          {
            question: ongoing_question,
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            weight: Faker::Number.number(digits: 1),
            selected: Faker::Boolean.boolean(true_ratio: 0.2), # false
            votes_count: 0
          },
          visibility: "all"
        )

        Decidim::Attachment.create!(
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          description: Decidim::Faker::Localized.sentence(word_count: 5),
          attached_to: answer,
          file: File.new(File.join(__dir__, "seeds", "city.jpeg")) # Keep after attached_to
        )
      end
    end

    questionnaire = Decidim::Forms::Questionnaire.create!(
      title: Decidim::Faker::Localized.paragraph,
      description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(sentence_count: 3)
      end,
      tos: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(sentence_count: 2)
      end,
      questionnaire_for: ongoing_election
    )

    %w(short_answer long_answer).each do |text_question_type|
      Decidim::Forms::Question.create!(
        questionnaire: questionnaire,
        body: Decidim::Faker::Localized.paragraph,
        question_type: text_question_type
      )
    end

    %w(single_option multiple_option).each do |multiple_choice_question_type|
      question = Decidim::Forms::Question.create!(
        questionnaire: questionnaire,
        body: Decidim::Faker::Localized.paragraph,
        question_type: multiple_choice_question_type
      )

      3.times do
        question.answer_options.create!(body: Decidim::Faker::Localized.sentence)
      end
    end
  end
end

Decidim.register_global_engine(
  :decidim_elections_trustee_zone,
  Decidim::Elections::TrusteeZoneEngine,
  at: "/trustee"
)

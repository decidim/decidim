# frozen_string_literal: true

require "decidim/components/namer"

Decidim.register_component(:surveys) do |component|
  component.engine = Decidim::Surveys::Engine
  component.admin_engine = Decidim::Surveys::AdminEngine
  component.icon = "media/images/decidim_surveys.svg"
  component.stylesheet = "decidim/surveys/surveys"
  component.permissions_class_name = "Decidim::Surveys::Permissions"
  component.serializes_specific_data = true
  component.specific_data_serializer_class_name = "Decidim::Surveys::DataSerializer"
  component.specific_data_importer_class_name = "Decidim::Surveys::DataImporter"
  component.query_type = "Decidim::Surveys::SurveysType"

  component.on(:copy) do |context|
    Decidim::Surveys::CreateSurvey.call(context[:new_component]) do
      on(:invalid) { raise "Can't create survey" }
    end
  end

  component.on(:create) do |instance|
    Decidim::Surveys::CreateSurvey.call(instance) do
      on(:invalid) { raise "Can't create survey" }
    end
  end

  component.data_portable_entities = ["Decidim::Forms::Answer"]

  component.newsletter_participant_entities = ["Decidim::Forms::Answer"]

  component.on(:before_destroy) do |instance|
    survey = Decidim::Surveys::Survey.find_by(decidim_component_id: instance.id)
    survey_answers_for_component = Decidim::Forms::Answer.where(questionnaire: survey.questionnaire)

    raise "Can't destroy this component when there are survey answers" if survey_answers_for_component.any?
  end

  component.register_resource(:survey) do |resource|
    resource.model_class_name = "Decidim::Surveys::Survey"
  end

  component.register_stat :surveys_count do |components, start_at, end_at|
    surveys = Decidim::Surveys::Survey.where(component: components)
    surveys = surveys.where("created_at >= ?", start_at) if start_at.present?
    surveys = surveys.where("created_at <= ?", end_at) if end_at.present?
    surveys.count
  end

  component.register_stat :answers_count, primary: true, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, start_at, end_at|
    surveys = Decidim::Surveys::Survey.includes(:questionnaire).where(component: components)
    answers = Decidim::Forms::Answer.where(questionnaire: surveys.map(&:questionnaire))
    answers = answers.where("created_at >= ?", start_at) if start_at.present?
    answers = answers.where("created_at <= ?", end_at) if end_at.present?
    answers.group(:session_token).count.size
  end

  # These actions permissions can be configured in the admin panel
  component.actions = %w(answer)

  component.settings(:global) do |settings|
    settings.attribute :scopes_enabled, type: :boolean, default: false
    settings.attribute :scope_id, type: :scope
    settings.attribute :starts_at, type: :time
    settings.attribute :ends_at, type: :time
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :clean_after_publish, type: :boolean, default: true
  end

  component.settings(:step) do |settings|
    settings.attribute :allow_answers, type: :boolean, default: false
    settings.attribute :allow_unregistered, type: :boolean, default: false
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.exports :survey_user_answers do |exports|
    exports.collection do |f|
      survey = Decidim::Surveys::Survey.find_by(component: f)
      Decidim::Forms::QuestionnaireUserAnswers.for(survey.questionnaire)
    end

    exports.formats %w(CSV JSON Excel FormPDF)

    exports.serializer Decidim::Forms::UserAnswersSerializer
  end

  component.seeds do |participatory_space|
    admin_user = Decidim::User.find_by(
      organization: participatory_space.organization,
      email: "admin@example.org"
    )

    params = {
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :surveys).i18n_name,
      manifest_name: :surveys,
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
      component: component,
      questionnaire: questionnaire
    }

    Decidim.traceability.create!(
      Decidim::Surveys::Survey,
      admin_user,
      params,
      visibility: "all"
    )

    %w(short_answer long_answer).each_with_index do |text_question_type, index|
      Decidim::Forms::Question.create!(
        questionnaire: questionnaire,
        body: Decidim::Faker::Localized.paragraph,
        question_type: text_question_type,
        position: index
      )
    end

    %w(single_option multiple_option).each_with_index do |multiple_choice_question_type, index|
      question = Decidim::Forms::Question.create!(
        questionnaire: questionnaire,
        body: Decidim::Faker::Localized.paragraph,
        question_type: multiple_choice_question_type,
        position: index + 2
      )

      3.times do
        question.answer_options.create!(body: Decidim::Faker::Localized.sentence)
      end

      question.display_conditions.create!(
        condition_question: questionnaire.questions.find_by(position: question.position - 2),
        question: question,
        condition_type: :answered,
        mandatory: true
      )
    end

    %w(matrix_single matrix_multiple).each_with_index do |matrix_question_type, index|
      question = Decidim::Forms::Question.create!(
        questionnaire: questionnaire,
        body: Decidim::Faker::Localized.paragraph,
        question_type: matrix_question_type,
        position: index
      )

      3.times do |position|
        question.answer_options.create!(body: Decidim::Faker::Localized.sentence)
        question.matrix_rows.create!(body: Decidim::Faker::Localized.sentence, position: position)
      end
    end
  end
end

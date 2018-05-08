# frozen_string_literal: true

require "decidim/components/namer"

Decidim.register_component(:surveys) do |component|
  component.engine = Decidim::Surveys::Engine
  component.admin_engine = Decidim::Surveys::AdminEngine
  component.icon = "decidim/surveys/icon.svg"
  component.stylesheet = "decidim/surveys/surveys"
  component.permissions_class_name = "Decidim::Surveys::Permissions"

  component.on(:create) do |instance|
    Decidim::Surveys::CreateSurvey.call(instance) do
      on(:invalid) { raise "Can't create survey" }
    end
  end

  component.on(:before_destroy) do |instance|
    raise "Can't destroy this component when there are surveys" if Decidim::Surveys::Survey.where(component: instance).any?
  end

  component.register_stat :surveys_count do |components, start_at, end_at|
    surveys = Decidim::Surveys::Survey.where(component: components)
    surveys = surveys.where("created_at >= ?", start_at) if start_at.present?
    surveys = surveys.where("created_at <= ?", end_at) if end_at.present?
    surveys.count
  end

  component.register_stat :answers_count, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, start_at, end_at|
    surveys = Decidim::Surveys::Survey.where(component: components)
    answers = Decidim::Surveys::SurveyAnswer.where(survey: surveys)
    answers = answers.where("created_at >= ?", start_at) if start_at.present?
    answers = answers.where("created_at <= ?", end_at) if end_at.present?
    answers.group(:decidim_user_id).count.size
  end

  # These actions permissions can be configured in the admin panel
  component.actions = %w(answer)

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :allow_answers, type: :boolean, default: false
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  # component.register_resource do |resource|
  #   # Register a optional resource that can be references from other resources.
  #   resource.model_class_name = "Decidim::Surveys::SomeResource"
  #   resource.template = "decidim/surveys/some_resources/linked_some_resources"
  # end

  # component.register_stat :some_stat do |context, start_at, end_at|
  #   # Register some stat number to the application
  # end

  component.exports :survey_user_answers do |exports|
    exports.collection do |f|
      survey = Decidim::Surveys::Survey.find_by(component: f)
      Decidim::Surveys::SurveyUserAnswers.for(survey)
    end

    exports.serializer Decidim::Surveys::SurveyUserAnswersSerializer
  end

  component.seeds do |participatory_space|
    component = Decidim::Component.create!(
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :surveys).i18n_name,
      manifest_name: :surveys,
      published_at: Time.current,
      participatory_space: participatory_space
    )

    survey = Decidim::Surveys::Survey.create!(
      component: component,
      title: Decidim::Faker::Localized.paragraph,
      description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(3)
      end,
      tos: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(2)
      end
    )

    %w(short_answer long_answer).each do |text_question_type|
      Decidim::Surveys::SurveyQuestion.create!(
        survey: survey,
        body: Decidim::Faker::Localized.paragraph,
        question_type: text_question_type
      )
    end

    %w(single_option multiple_option).each do |multiple_choice_question_type|
      question = Decidim::Surveys::SurveyQuestion.create!(
        survey: survey,
        body: Decidim::Faker::Localized.paragraph,
        question_type: multiple_choice_question_type
      )

      3.times do
        question.answer_options.create!(body: Decidim::Faker::Localized.sentence)
      end
    end
  end
end

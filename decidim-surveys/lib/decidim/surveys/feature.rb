# frozen_string_literal: true

require_dependency "decidim/features/namer"

Decidim.register_feature(:surveys) do |feature|
  feature.engine = Decidim::Surveys::Engine
  feature.admin_engine = Decidim::Surveys::AdminEngine
  feature.icon = "decidim/surveys/icon.svg"
  feature.stylesheet = "decidim/surveys/surveys"

  feature.on(:create) do |instance|
    Decidim::Surveys::CreateSurvey.call(instance) do
      on(:invalid) { raise "Can't create survey" }
    end
  end

  feature.on(:before_destroy) do |instance|
    if Decidim::Surveys::Survey.where(feature: instance).any?
      raise "Can't destroy this feature when there are surveys"
    end
  end

  feature.register_stat :surveys_count do |features, start_at, end_at|
  surveys = Decidim::Surveys::Survey.where(feature: featuresa)
    surveys = surveys.where("created_at >= ?", start_at) if start_at.present?
    surveys = surveys.where("created_at <= ?", end_at) if end_at.present?
    surveys.count
  end

  feature.register_stat :answers_count, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |features, start_at, end_at|
    surveys = Decidim::Surveys::Survey.where(feature: features)
    answers = Decidim::Surveys::SurveyAnswer.where(survey: surveys)
    answers = answers.where("created_at >= ?", start_at) if start_at.present?
    answers = answers.where("created_at <= ?", end_at) if end_at.present?
    answers.group(:decidim_user_id).count.size
  end

  # These actions permissions can be configured in the admin panel
  feature.actions = %w(answer)

  # feature.settings(:global) do |settings|
  #   # Add your global settings
  #   # Available types: :integer, :boolean
  #   # settings.attribute :vote_limit, type: :integer, default: 0
  # end

  feature.settings(:step) do |settings|
    settings.attribute :allow_answers, type: :boolean, default: false
  end

  # feature.register_resource do |resource|
  #   # Register a optional resource that can be references from other resources.
  #   resource.model_class_name = "Decidim::Surveys::SomeResource"
  #   resource.template = "decidim/surveys/some_resources/linked_some_resources"
  # end

  # feature.register_stat :some_stat do |context, start_at, end_at|
  #   # Register some stat number to the application
  # end

  feature.exports :survey_user_answers do |exports|
    exports.collection do |f|
      survey = Decidim::Surveys::Survey.where(feature: f).first
      Decidim::Surveys::SurveyUserAnswers.for(survey)
    end

    exports.serializer Decidim::Surveys::SurveyUserAnswersSerializer
  end

  feature.seeds do
    Decidim::ParticipatoryProcess.find_each do |process|
      next unless process.steps.any?

      feature = Decidim::Feature.create!(
        name: Decidim::Features::Namer.new(process.organization.available_locales, :surveys).i18n_name,
        manifest_name: :surveys,
        published_at: Time.current,
        participatory_process: process
      )

      survey = Decidim::Surveys::Survey.create!(
        feature: feature,
        title: Decidim::Faker::Localized.paragraph,
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        tos: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(2)
        end
      )

      3.times do
        Decidim::Surveys::SurveyQuestion.create!(
          survey: survey,
          body: Decidim::Faker::Localized.paragraph,
          question_type: "short_answer"
        )
      end
    end
  end
end

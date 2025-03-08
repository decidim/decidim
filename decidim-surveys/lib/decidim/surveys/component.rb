# frozen_string_literal: true

Decidim.register_component(:surveys) do |component|
  component.engine = Decidim::Surveys::Engine
  component.admin_engine = Decidim::Surveys::AdminEngine
  component.icon = "media/images/decidim_surveys.svg"
  component.icon_key = "survey-line"
  component.stylesheet = "decidim/surveys/surveys"
  component.permissions_class_name = "Decidim::Surveys::Permissions"
  component.serializes_specific_data = true
  component.specific_data_serializer_class_name = "Decidim::Surveys::DataSerializer"
  component.specific_data_importer_class_name = "Decidim::Surveys::DataImporter"
  component.query_type = "Decidim::Surveys::SurveysType"

  component.data_portable_entities = ["Decidim::Forms::Answer"]

  component.newsletter_participant_entities = ["Decidim::Forms::Answer"]

  component.on(:before_destroy) do |instance|
    survey = Decidim::Surveys::Survey.find_by(decidim_component_id: instance.id)
    survey_answers_for_component = Decidim::Forms::Answer.where(questionnaire: survey.questionnaire)

    raise "Cannot destroy this component when there are survey answers" if survey_answers_for_component.any?
  end

  component.register_resource(:survey) do |resource|
    resource.model_class_name = "Decidim::Surveys::Survey"
    resource.card = "decidim/surveys/survey"
    resource.actions = %w(answer)
  end

  component.register_stat :surveys_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, start_at, end_at|
    surveys = Decidim::Surveys::Survey.where(component: components)
    surveys = surveys.where(created_at: start_at..) if start_at.present?
    surveys = surveys.where(created_at: ..end_at) if end_at.present?
    surveys.count
  end

  component.register_stat :answers_count, primary: true, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, start_at, end_at|
    surveys = Decidim::Surveys::Survey.includes(:questionnaire).where(component: components)
    answers = Decidim::Forms::Answer.where(questionnaire: surveys.map(&:questionnaire))
    answers = answers.where(created_at: start_at..) if start_at.present?
    answers = answers.where(created_at: ..end_at) if end_at.present?
    answers.group(:session_token).count.size
  end

  # These actions permissions can be configured in the admin panel
  component.actions = %w(answer)

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
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
    require "decidim/surveys/seeds"

    Decidim::Surveys::Seeds.new(participatory_space:).call
  end
end

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

  component.on(:publish) do |instance|
    Decidim::Surveys::Survey.where(component: instance).find_each do |result|
      Decidim::UpdateSearchIndexesJob.perform_later([result])
    end
  end

  component.on(:unpublish) do |instance|
    Decidim::Surveys::Survey.where(component: instance).find_each do |result|
      Decidim::RemoveSearchIndexesJob.perform_later([result])
    end
  end

  component.data_portable_entities = ["Decidim::Forms::Response"]

  component.newsletter_participant_entities = ["Decidim::Forms::Response"]

  component.register_resource(:survey) do |resource|
    resource.model_class_name = "Decidim::Surveys::Survey"
    resource.card = "decidim/surveys/survey"
    resource.searchable = true
    resource.actions = %w(respond)
  end

  component.register_stat :surveys_count,
                          primary: true,
                          priority: Decidim::StatsRegistry::MEDIUM_PRIORITY,
                          sub_title: "responses",
                          icon_name: "survey-line",
                          tooltip_key: "surveys_count_tooltip" do |components, start_at, end_at|
    surveys = Decidim::Surveys::Survey.where(component: components)
    surveys = surveys.where(created_at: start_at..) if start_at.present?
    surveys = surveys.where(created_at: ..end_at) if end_at.present?
    first = surveys.count
    participatory_space_surveys = Decidim::Surveys::Survey.includes(:questionnaire).where(component: components)
    responses = Decidim::Forms::Response.where(questionnaire: participatory_space_surveys.map(&:questionnaire))
    responses = responses.where(created_at: start_at..) if start_at.present?
    responses = responses.where(created_at: ..end_at) if end_at.present?
    [
      first,
      responses.group(:session_token).count.size
    ]
  end

  # These actions permissions can be configured in the admin panel
  component.actions = %w(respond)

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.exports :survey_user_responses do |exports|
    exports.collection do |_component, _user, survey_id|
      survey = Decidim::Surveys::Survey.find(survey_id)
      Decidim::Forms::QuestionnaireUserResponses.for(survey.questionnaire)
    end

    exports.formats %w(CSV JSON Excel FormPDF)

    exports.serializer Decidim::Forms::UserResponsesSerializer
  end

  component.exports :published_survey_user_responses do |exports|
    exports.collection do |component|
      survey = Decidim::Surveys::Survey.find_by(component:)

      Decidim::Forms::Response
        .joins(:question)
        .where(questionnaire: survey.questionnaire)
        .where.not(decidim_forms_questions: { question_type: %w(separator title_and_description) })
        .where.not(decidim_forms_questions: { survey_responses_published_at: nil })
        .includes(:question, :choices, :user)
    end

    exports.formats []
    exports.include_in_open_data = true
    exports.serializer Decidim::Surveys::UserResponsesSerializer
  end

  component.seeds do |participatory_space|
    require "decidim/surveys/seeds"

    Decidim::Surveys::Seeds.new(participatory_space:).call
  end
end

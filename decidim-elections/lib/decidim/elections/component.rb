# frozen_string_literal: true

Decidim.register_component(:elections) do |component|
  component.engine = Decidim::Elections::Engine
  component.admin_engine = Decidim::Elections::AdminEngine
  component.icon = "media/images/decidim_elections.svg"
  component.icon_key = "check-double-fill"
  component.stylesheet = "decidim/elections/elections"
  component.permissions_class_name = "Decidim::Elections::Permissions"
  component.query_type = "Decidim::Elections::ElectionsType"

  component.on(:before_destroy) do |instance|
    raise StandardError, "Cannot remove this component" if Decidim::Elections::Election.where(component: instance).any?
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
    elections.published.count
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
      Decidim::Elections::Answer
        .where(decidim_elections_question_id: Decidim::Elections::Election.where(component: component_instance).bb_results_published.extract_associated(:questions))
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Elections::AnswerSerializer
  end

  component.seeds do |participatory_space|
    require "decidim/elections/seeds"

    Decidim::Elections::Seeds.new(participatory_space:).call
  end
end

Decidim.register_global_engine(
  :decidim_elections_trustee_zone,
  Decidim::Elections::TrusteeZoneEngine,
  at: "/trustee"
)

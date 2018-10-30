# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :surveys_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :surveys).i18n_name }
    manifest_name { :surveys }
    participatory_space { create(:participatory_process, :with_steps) }
  end

  factory :survey, class: Decidim::Surveys::Survey do
    title { Decidim::Faker::Localized.sentence }
    description do
      Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.sentence(4)
      end
    end
    tos { Decidim::Faker::Localized.sentence(4) }
    component { build(:surveys_component) }
  end

  factory :survey_question, class: Decidim::Surveys::SurveyQuestion do
    transient do
      answer_options { [] }
    end

    body { Decidim::Faker::Localized.sentence }
    mandatory { false }
    position { 0 }
    question_type { Decidim::Surveys::SurveyQuestion::TYPES.first }
    survey

    before(:create) do |question, evaluator|
      evaluator.answer_options.each do |answer_option|
        question.answer_options.build(
          body: answer_option["body"],
          free_text: answer_option["free_text"]
        )
      end
    end
  end

  factory :survey_answer, class: Decidim::Surveys::SurveyAnswer do
    body { "hola" }
    survey
    question { create(:survey_question, survey: survey) }
    user { create(:user, organization: survey.organization) }
  end

  factory :survey_answer_option, class: Decidim::Surveys::SurveyAnswerOption do
    body { Decidim::Faker::Localized.sentence }
  end

  factory :survey_answer_choice, class: Decidim::Surveys::SurveyAnswerChoice do
  end
end

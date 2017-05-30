# frozen_string_literal: true
require "decidim/core/test/factories"

FactoryGirl.define do
  factory :surveys_feature, parent: :feature do
    name { Decidim::Features::Namer.new(participatory_process.organization.available_locales, :surveys).i18n_name }
    manifest_name :surveys
    participatory_process { create(:participatory_process, :with_steps) }
  end

  factory :survey, class: Decidim::Surveys::Survey do
    title { Decidim::Faker::Localized.sentence }
    description do
      Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.sentence(4)
      end
    end
    toc { Decidim::Faker::Localized.sentence(4) }
    feature { build(:surveys_feature) }
  end

  factory :survey_question, class: Decidim::Surveys::SurveyQuestion do
    body { Decidim::Faker::Localized.sentence }
    mandatory false
    position 0
    question_type Decidim::Surveys::SurveyQuestion::TYPES.first
    answer_options []
    survey
  end

  factory :survey_answer, class: Decidim::Surveys::SurveyAnswer do
    body { Decidim::Faker::Localized.sentence }
    survey
    question { create(:survey_question, survey: survey) }
  end
end

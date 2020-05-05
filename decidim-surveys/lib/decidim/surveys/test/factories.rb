# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/forms/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :surveys_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :surveys).i18n_name }
    manifest_name { :surveys }
    participatory_space { create(:participatory_process, :with_steps) }
  end

  factory :survey, class: "Decidim::Surveys::Survey" do
    transient do
      questionnaire { :default_value }
      questionnaires_count { 1 }
    end

    questionnaires { questionnaires_count.times.map { build(:questionnaire) } }
    component { build(:surveys_component) }

    after(:build) do |survey, evaluator|
      if evaluator.questionnaire != :default_value
        survey.questionnaires = [evaluator.questionnaire].flatten.compact
      end
    end
  end
end

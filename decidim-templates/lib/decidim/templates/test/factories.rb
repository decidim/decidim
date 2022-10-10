# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.define do
  factory :template, class: "Decidim::Templates::Template" do
    organization
    templatable { build(:dummy_resource) }
    name { Decidim::Faker::Localized.sentence }

    trait :proposal_answer do
      templatable { organization }
      target { :proposal_answer }
      field_values { { internal_state: :accepted } }
    end

    ## Questionnaire templates
    factory :questionnaire_template do
      trait :with_questions do
        after(:create) do |template|
          template.templatable = create(:questionnaire, :with_questions, questionnaire_for: template)
          template.save!
        end
      end

      trait :with_all_questions do
        after(:create) do |template|
          template.templatable = create(:questionnaire, :with_all_questions, questionnaire_for: template)
          template.save!
        end
      end

      after(:create) do |template|
        template.templatable = create(:questionnaire, questionnaire_for: template)
        template.save!
      end
    end
  end
end

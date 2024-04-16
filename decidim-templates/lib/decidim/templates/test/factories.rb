# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.define do
  factory :template, class: "Decidim::Templates::Template" do
    transient do
      skip_injection { false }
    end
    organization
    name { generate_localized_title(:template_name, skip_injection: skip_injection) }
    description { generate_localized_title(:template_description, skip_injection: skip_injection) }
    templatable { build(:dummy_resource, skip_injection: skip_injection) }

    ## Questionnaire templates
    factory :questionnaire_template do
      transient do
        skip_injection { false }
      end
      trait :with_questions do
        after(:create) do |template, evaluator|
          template.templatable = create(:questionnaire, :with_questions, questionnaire_for: template, skip_injection: evaluator.skip_injection)
          template.save!
        end
      end

      trait :with_all_questions do
        after(:create) do |template, evaluator|
          template.templatable = create(:questionnaire, :with_all_questions, questionnaire_for: template, skip_injection: evaluator.skip_injection)
          template.save!
        end
      end

      after(:create) do |template, evaluator|
        template.templatable = create(:questionnaire, questionnaire_for: template, skip_injection: evaluator.skip_injection)
        template.save!
      end
    end
  end
end

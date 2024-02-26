# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.define do
  factory :template, class: "Decidim::Templates::Template" do
    transient do
      skip_injection { false }
    end
    organization
    name { generate_localized_title(:template_name, skip_injection:) }
    description { generate_localized_title(:template_description, skip_injection:) }
    target { "generic-template" }
    templatable { build(:dummy_resource, skip_injection:) }

    trait :user_block do
      templatable { organization }
      target { :user_block }
    end

    trait :proposal_answer do
      templatable { organization }
      target { :proposal_answer }
      field_values { { internal_state: :accepted } }
    end

    ## Questionnaire templates
    factory :questionnaire_template do
      transient do
        skip_injection { false }
      end
      target { "questionnaire" }

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

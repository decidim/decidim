# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/core/test/factories"
require "decidim/forms/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :surveys_component, parent: :component do
    transient do
      skip_injection { false }
    end
    name { generate_component_name(participatory_space.organization.available_locales, :surveys, skip_injection:) }
    manifest_name { :surveys }
    participatory_space { create(:participatory_process, :with_steps, skip_injection:) }
  end

  factory :survey, class: "Decidim::Surveys::Survey" do
    transient do
      skip_injection { false }
    end
    questionnaire { build(:questionnaire, :with_questions, skip_injection:) }
    component { build(:surveys_component, skip_injection:) }

    trait :published do
      published_at { Time.current }
    end

    trait :allow_edit do
      allow_editing_responses { true }
    end

    trait :allow_responses do
      allow_responses { true }
    end

    trait :allow_unregistered do
      allow_unregistered { true }
    end

    trait :clean_after_publish do
      clean_after_publish { true }
    end

    trait :announcement do
      announcement { "This is a custom announcement." }
    end
  end
end

# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/faker/localized"
require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :elections_component, parent: :component do
    transient do
      skip_injection { false }
    end

    name { generate_component_name(participatory_space.organization.available_locales, :elections, skip_injection:) }
    manifest_name { :elections }
    participatory_space { create(:participatory_process, :with_steps, skip_injection:, organization:) }
  end

  factory :election, class: "Decidim::Elections::Election" do
    transient do
      skip_injection { false }
    end
    title { generate_localized_title(:election_title, skip_injection:) }
    description { generate_localized_description(:election_description, skip_injection:) }
    start_at { nil }
    end_at { 30.days.from_now }

    component { create(:elections_component, skip_injection:) }

    published_at { Time.current }
    deleted_at { nil }

    trait :unpublished do
      published_at { nil }
    end

    trait :with_image do
      after :create do |election, evaluator|
        election.attachments << create(:attachment, :with_image, attached_to: election, skip_injection: evaluator.skip_injection)
      end
    end
  end
end

# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :collaborative_texts_component, parent: :component do
    transient do
      skip_injection { false }
    end

    name { generate_component_name(participatory_space.organization.available_locales, :collaborative_texts, skip_injection:) }
    manifest_name { :collaborative_texts }
    participatory_space { create(:participatory_process, :with_steps, skip_injection:, organization:) }
  end

  factory :collaborative_text_document, class: "Decidim::CollaborativeTexts::Document" do
    transient do
      skip_injection { false }
    end
    title { generate_title(:collaborative_text_document_title, skip_injection:) }
    component { create(:collaborative_texts_component, skip_injection:) }

    trait :with_body do
      body { Faker::HTML.paragraph }
    end

    trait :with_versions do
      after(:build) do |document, _evaluator|
        document.document_versions = build_list(:collaborative_text_version, 3, document: document)
      end
    end

    trait :published do
      published_at { Time.current }
    end
  end

  factory :collaborative_text_version, class: "Decidim::CollaborativeTexts::Version" do
    body { Faker::HTML.paragraph }
    document { create(:collaborative_text_document) }

    trait :draft do
      draft { true }
    end
  end
end

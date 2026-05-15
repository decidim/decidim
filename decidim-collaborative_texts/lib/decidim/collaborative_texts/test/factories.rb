# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :collaborative_text_component, parent: :component do
    transient do
      skip_injection { false }
    end

    name { generate_component_name(participatory_space.organization.available_locales, :collaborative_texts, skip_injection:) }
    manifest_name { :collaborative_texts }
    participatory_space { create(:participatory_process, :with_steps, skip_injection:, organization:) }
  end

  factory :collaborative_text_document, class: "Decidim::CollaborativeTexts::Document" do
    transient do
      users { nil }
      skip_injection { false }
    end
    title { generate_title(:collaborative_text_document_title, skip_injection:) }
    component { create(:collaborative_text_component, skip_injection:) }

    trait :with_body do
      body { Faker::HTML.paragraph }
    end

    trait :with_versions do
      document_versions { build_list(:collaborative_text_version, 3) }
    end

    trait :published do
      published_at { Time.current }
    end

    after :build do |document, evaluator|
      if document.component
        users = evaluator.users || [document.component.organization]
        users.each do |user|
          document.coauthorships.build(author: user)
        end
      end
    end
  end

  factory :collaborative_text_version, class: "Decidim::CollaborativeTexts::Version" do
    body { Faker::HTML.paragraph }
    document { create(:collaborative_text_document) }
    draft { false }

    trait :draft do
      draft { true }
    end
  end

  factory :collaborative_text_suggestion, class: "Decidim::CollaborativeTexts::Suggestion" do
    document_version { build(:collaborative_text_version) }
    author { build(:user, :confirmed, organization: document_version.document.organization) }
    trait :pending do
      status { :pending }
    end
    trait :accepted do
      status { :accepted }
    end
    trait :rejected do
      status { :rejected }
    end

    changeset do
      {
        firstNode: "1",
        lastNode: "2",
        original: [Faker::HTML.paragraph(sentence_count: rand(1..3))],
        replace: [Faker::HTML.paragraph(sentence_count: rand(1..3))]
      }
    end
  end
end

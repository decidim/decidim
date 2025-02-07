# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/faker/localized"
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
    title { "Default title" }
    component { create(:collaborative_texts_component, skip_injection:) }

    trait :published do
      published_at { Time.current }
    end

    factory :published_collaborative_text do
      published_at { Time.current }
    end
  end
end

# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/forms/test/factories"

FactoryBot.define do
  sequence(:voting_slug) do |n|
    "#{Decidim::Faker::Internet.slug(words: nil, glue: "-")}-#{n}"
  end

  factory :voting, class: "Decidim::Votings::Voting" do
    organization
    slug { generate(:voting_slug) }
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    published_at { Time.current }
    start_time { 1.day.from_now }
    end_time { 3.days.from_now }
    decidim_scope_id { create(:scope, organization: organization).id }

    trait :unpublished do
      published_at { nil }
    end

    trait :published do
      published_at { Time.current }
    end
  end
end

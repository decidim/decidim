# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryGirl.define do
  sequence(:assembly_slug) do |n|
    "#{Faker::Internet.slug(nil, "-")}-#{n}"
  end

  factory :assembly, class: Decidim::Assembly do
    title { Decidim::Faker::Localized.sentence(3) }
    slug { generate(:assembly_slug) }
    subtitle { Decidim::Faker::Localized.sentence(1) }
    short_description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    hero_image { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    banner_image { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }
    published_at { Time.current }
    organization
    meta_scope { Decidim::Faker::Localized.word }
    developer_group { Decidim::Faker::Localized.sentence(1) }
    local_area { Decidim::Faker::Localized.sentence(2) }
    target { Decidim::Faker::Localized.sentence(3) }
    participatory_scope { Decidim::Faker::Localized.sentence(1) }
    participatory_structure { Decidim::Faker::Localized.sentence(2) }
    show_statistics true

    trait :promoted do
      promoted true
    end

    trait :unpublished do
      published_at nil
    end

    trait :published do
      published_at { Time.current }
    end
  end
end

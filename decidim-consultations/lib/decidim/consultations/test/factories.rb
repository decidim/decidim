# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.define do
  sequence(:consultation_slug) do |n|
    "#{Faker::Internet.slug(nil, "-")}-#{n}"
  end

  sequence(:question_slug) do |n|
    "#{Faker::Internet.slug(nil, "-")}-#{n}"
  end

  factory :consultation, class: "Decidim::Consultation" do
    organization
    slug { generate(:consultation_slug) }
    title { Decidim::Faker::Localized.sentence(3) }
    subtitle { Decidim::Faker::Localized.sentence(1) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    banner_image { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }
    published_at { Time.current }
    start_voting_date { Time.zone.today }
    end_voting_date { Time.zone.today + 1.month }
    introductory_video_url { "https://www.youtube.com/embed/zhMMW0TENNA" }
    decidim_highlighted_scope_id { create(:scope, organization: organization).id }
    results_published_at { nil }

    trait :unpublished do
      published_at { nil }
    end

    trait :published do
      published_at { Time.current }
    end

    trait :unpublished_results do
      results_published_at { nil }
    end

    trait :published_results do
      results_published_at { Time.current }
    end

    trait :upcoming do
      start_voting_date { Time.zone.today + 7.days }
      end_voting_date { Time.zone.today + 1.month + 7.days }
    end

    trait :active do
      start_voting_date { Time.zone.today - 7.days }
      end_voting_date { Time.zone.today - 7.days + 1.month }
    end

    trait :finished do
      start_voting_date { Time.zone.today - 7.days - 1.month }
      end_voting_date { Time.zone.today - 7.days }
    end
  end

  factory :question, class: "Decidim::Consultations::Question" do
    consultation
    organization { consultation.organization }
    scope { create(:scope, organization: consultation.organization) }
    slug { generate(:question_slug) }
    title { Decidim::Faker::Localized.sentence(3) }
    subtitle { Decidim::Faker::Localized.sentence(3) }
    promoter_group { Decidim::Faker::Localized.sentence(3) }
    participatory_scope { Decidim::Faker::Localized.sentence(3) }
    question_context { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    what_is_decided { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    published_at { Time.current }
    hero_image { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    banner_image { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }
    external_voting { false }
    sequence :order do |n|
      n
    end

    trait :unpublished do
      published_at { nil }
    end

    trait :published do
      published_at { Time.current }
    end

    trait :external_voting do
      external_voting { true }
      i_frame_url { "http://example.org" }
    end
  end

  factory :response, class: "Decidim::Consultations::Response" do
    question
    title { Decidim::Faker::Localized.sentence(3) }
  end

  factory :vote, class: "Decidim::Consultations::Vote" do
    question
    response
    author { create(:user, organization: question.organization) }
  end
end

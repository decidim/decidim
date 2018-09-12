# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"
require "decidim/assemblies/test/factories"

FactoryBot.define do
  factory :meeting_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :meetings).i18n_name }
    manifest_name { :meetings }
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }
  end

  factory :meeting, class: "Decidim::Meetings::Meeting" do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    location { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    location_hints { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    address { Faker::Lorem.sentence(3) }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    start_time { 1.day.from_now }
    end_time { start_time.advance(hours: 2) }
    private_meeting { false }
    transparent { true }
    services do
      [
        { title: Decidim::Faker::Localized.sentence(2), description: Decidim::Faker::Localized.sentence(5) },
        { title: Decidim::Faker::Localized.sentence(2), description: Decidim::Faker::Localized.sentence(5) }
      ]
    end
    component { build(:component, manifest_name: "meetings") }

    organizer do
      create(:user, organization: component.organization) if component
    end

    trait :closed do
      closing_report { Decidim::Faker::Localized.sentence(3) }
      attendees_count { rand(50) }
      contributions_count { rand(50) }
      attending_organizations { Array.new(3) { Faker::GameOfThrones.house }.join(", ") }
      closed_at { Time.current }
    end

    trait :with_registrations_enabled do
      registrations_enabled { true }
      available_slots { 10 }
      reserved_slots { 4 }
      registration_terms { Decidim::Faker::Localized.sentence(3) }
    end

    trait :past do
      start_time { end_time.ago(2.hours) }
      end_time { Faker::Time.between(10.days.ago, 1.day.ago) }
    end

    trait :upcoming do
      start_time { Faker::Time.between(1.day.from_now, 10.days.from_now) }
    end
  end

  factory :registration, class: "Decidim::Meetings::Registration" do
    meeting
    user
  end

  factory :agenda, class: "Decidim::Meetings::Agenda" do
    meeting
    title { Decidim::Faker::Localized.sentence(3) }
    visible { true }

    trait :with_agenda_items do
      after(:create) do |agenda, _evaluator|
        create_list(:agenda_item, 2, :with_children, agenda: agenda)
      end
    end
  end

  factory :agenda_item, class: "Decidim::Meetings::AgendaItem" do
    agenda
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    duration { 15 }
    position { 0 }

    trait :with_parent do
      parent { create(:agenda_item, agenda: agenda) }
    end

    trait :with_children do
      after(:create) do |agenda_item, evaluator|
        create_list(:agenda_item, 2, parent: agenda_item, agenda: evaluator.agenda)
      end
    end
  end

  factory :minutes, class: "Decidim::Meetings::Minutes" do
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    video_url { Faker::Internet.url }
    audio_url { Faker::Internet.url }
    visible { true }
    meeting
  end

  factory :invite, class: "Decidim::Meetings::Invite" do
    meeting
    user
    sent_at { Time.current - 1.day }
    accepted_at { nil }
    rejected_at { nil }

    trait :accepted do
      accepted_at { Time.current }
    end

    trait :rejected do
      rejected_at { Time.current }
    end
  end
end

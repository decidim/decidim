# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/forms/test/factories"
require "decidim/participatory_processes/test/factories"
require "decidim/assemblies/test/factories"

FactoryBot.define do
  factory :meeting_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :meetings).i18n_name }
    manifest_name { :meetings }
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }

    trait :with_creation_enabled do
      settings do
        {
          creation_enabled_for_participants: true
        }
      end
    end
  end

  factory :meeting, class: "Decidim::Meetings::Meeting" do
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    location { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    location_hints { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    address { Faker::Lorem.sentence(3) }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    start_time { 1.day.from_now }
    end_time { start_time.advance(hours: 2) }
    private_meeting { false }
    transparent { true }
    services do
      [
        { title: generate_localized_title, description: generate_localized_title },
        { title: generate_localized_title, description: generate_localized_title }
      ]
    end
    questionnaire { build(:questionnaire) }
    registration_form_enabled { true }
    component { build(:component, manifest_name: "meetings") }

    organizer do
      component.organization if component
    end
    organizer_type do
      organizer.class.name
    end

    trait :official do
      organizer { component.organization if component }
    end

    trait :not_official do
      organizer { create(:user, organization: component.organization) if component }
      organizer_type do
        "Decidim::UserBaseEntity"
      end
    end

    trait :by_user_group do
      organizer { create(:user_group, :verified, organization: component.organization) if component }
    end

    trait :closed do
      closing_report { generate_localized_title }
      attendees_count { rand(50) }
      contributions_count { rand(50) }
      attending_organizations { Array.new(3) { Faker::TvShows::GameOfThrones.house }.join(", ") }
      closed_at { Time.current }
    end

    trait :with_registrations_enabled do
      registrations_enabled { true }
      available_slots { 10 }
      reserved_slots { 4 }
      registration_terms { generate_localized_title }
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
    title { generate_localized_title }
    visible { true }

    trait :with_agenda_items do
      after(:create) do |agenda, _evaluator|
        create_list(:agenda_item, 2, :with_children, agenda: agenda)
      end
    end
  end

  factory :agenda_item, class: "Decidim::Meetings::AgendaItem" do
    agenda
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
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
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
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

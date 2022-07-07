# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/forms/test/factories"
require "decidim/participatory_processes/test/factories"

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
    address { Faker::Lorem.sentence(word_count: 3) }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    start_time { 1.day.from_now }
    end_time { start_time.advance(hours: 2) }
    private_meeting { false }
    transparent { true }
    questionnaire { build(:questionnaire) }
    registration_form_enabled { true }
    registration_terms { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    registration_type { :on_this_platform }
    type_of_meeting { :in_person }
    component { build(:component, manifest_name: "meetings") }
    iframe_access_level { :all }
    iframe_embed_type { :none }

    author do
      component.try(:organization)
    end

    trait :published do
      published_at { Time.current }
    end

    trait :withdrawn do
      state { "withdrawn" }
    end

    trait :in_person do
      type_of_meeting { :in_person }
    end

    trait :online do
      type_of_meeting { :online }
      online_meeting_url { "https://decidim.org" }
    end

    trait :hybrid do
      type_of_meeting { :hybrid }
      online_meeting_url { "https://decidim.org" }
    end

    trait :official do
      author { component.organization if component }
    end

    trait :not_official do
      author { create(:user, organization: component.organization) if component }
    end

    trait :with_services do
      transient do
        services do
          nil
        end
      end

      after(:build) do |meeting, evaluator|
        meeting.services = evaluator.services || build_list(:service, 2, meeting: meeting)
      end
    end

    trait(:participant_author) { not_official }

    trait :user_group_author do
      author do
        create(:user, organization: component.organization) if component
      end
      user_group do
        create(:user_group, :verified, organization: component.organization, users: [author]) if component
      end
    end

    trait :closed do
      closing_report { generate_localized_title }
      attendees_count { rand(50) }
      contributions_count { rand(50) }
      attending_organizations { Array.new(3) { Faker::TvShows::GameOfThrones.house }.join(", ") }
      closed_at { Time.current }
      closing_visible { true }
    end

    trait :closed_with_minutes do
      closed
      video_url { Faker::Internet.url }
      audio_url { Faker::Internet.url }
      closing_visible { true }
    end

    trait :with_registrations_enabled do
      registrations_enabled { true }
      available_slots { 10 }
      reserved_slots { 4 }
      registration_terms { generate_localized_title }
    end

    trait :past do
      start_time { end_time.ago(2.hours) }
      end_time { Faker::Time.between(from: 10.days.ago, to: 1.day.ago) }
    end

    trait :upcoming do
      start_time { Faker::Time.between(from: 1.day.from_now, to: 10.days.from_now) }
    end

    trait :live do
      start_time { 1.day.ago }
      end_time { 1.day.from_now }
    end

    trait :embeddable do
      online_meeting_url { "https://www.youtube.com/watch?v=pj_2G3x6-Zk" }
    end

    factory :published_meeting do
      published_at { Time.current }
    end

    trait :signed_in_iframe_access_level do
      iframe_access_level { :signed_in }
    end

    trait :registered_iframe_access_level do
      iframe_access_level { :registered }
    end

    trait :embed_in_meeting_page_iframe_embed_type do
      iframe_embed_type { :embed_in_meeting_page }
    end

    trait :open_in_live_event_page_iframe_embed_type do
      iframe_embed_type { :open_in_live_event_page }
    end

    trait :open_in_new_tab_iframe_embed_type do
      iframe_embed_type { :open_in_new_tab }
    end

    trait :moderated do
      after(:create) do |meeting, _evaluator|
        create(:moderation, reportable: meeting, hidden_at: 2.days.ago)
      end
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

  factory :invite, class: "Decidim::Meetings::Invite" do
    meeting
    user
    sent_at { 1.day.ago }
    accepted_at { nil }
    rejected_at { nil }

    trait :accepted do
      accepted_at { Time.current }
    end

    trait :rejected do
      rejected_at { Time.current }
    end
  end

  factory :service, class: "Decidim::Meetings::Service" do
    meeting
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
  end

  factory :poll, class: "Decidim::Meetings::Poll" do
    meeting
  end

  factory :meetings_poll_questionnaire, class: "Decidim::Meetings::Questionnaire" do
    questionnaire_for { build(:poll) }
  end

  factory :meetings_poll_question, class: "Decidim::Meetings::Question" do
    transient do
      options { [] }
    end

    body { generate_localized_title }
    position { 0 }
    status { 0 }
    question_type { Decidim::Meetings::Question::QUESTION_TYPES.first }
    questionnaire factory: :meetings_poll_questionnaire
    answer_options do
      Array.new(3).collect { build(:meetings_poll_answer_option, question: nil) }
    end

    trait :unpublished do
      status { 0 }
    end

    trait :published do
      status { 1 }
    end

    trait :closed do
      status { 2 }
    end
  end

  factory :meetings_poll_answer, class: "Decidim::Meetings::Answer" do
    questionnaire factory: :meetings_poll_questionnaire
    question { create(:meetings_poll_question, questionnaire: questionnaire) }
    user { create(:user, organization: questionnaire.questionnaire_for.organization) }
  end

  factory :meetings_poll_answer_option, class: "Decidim::Meetings::AnswerOption" do
    question { create(:meetings_poll_question) }
    body { generate_localized_title }
  end

  factory :meetings_poll_answer_choice, class: "Decidim::Meetings::AnswerChoice" do
    answer factory: :meetings_poll_answer
    answer_option { create(:meetings_poll_answer_option, question: answer.question) }
  end
end

# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/core/test/factories"
require "decidim/forms/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :meeting_component, parent: :component do
    transient do
      skip_injection { false }
    end
    name { generate_component_name(participatory_space.organization.available_locales, :meetings, skip_injection:) }
    manifest_name { :meetings }
    participatory_space { create(:participatory_process, :with_steps, organization:, skip_injection:) }

    trait :with_creation_enabled do
      settings do
        {
          creation_enabled_for_participants: true
        }
      end
    end
  end

  factory :meeting, class: "Decidim::Meetings::Meeting" do
    transient do
      skip_injection { false }
    end

    title { generate_localized_title(:meeting_title, skip_injection:) }
    description { generate_localized_description(:meeting_description, skip_injection:) }
    location { generate_localized_description(:meeting_location, skip_injection:) }
    location_hints { generate_localized_description(:meeting_location_hints, skip_injection:) }
    address { Faker::Lorem.sentence(word_count: 3) }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    start_time { 1.day.from_now }
    end_time { start_time.advance(hours: 2) }
    reminder_enabled { true }
    send_reminders_before_hours { 48 }
    reminder_message_custom_content { generate_localized_description(:meeting_reminder_message, skip_injection:) }
    private_meeting { false }
    transparent { true }
    questionnaire { build(:questionnaire) }
    registration_form_enabled { true }
    registration_terms { generate_localized_description(:meeting_registration_terms, skip_injection:) }
    registration_type { :on_this_platform }
    type_of_meeting { :in_person }
    component { build(:meeting_component) }
    iframe_access_level { :all }
    iframe_embed_type { :none }
    deleted_at { nil }

    author do
      component.try(:organization)
    end

    trait :published do
      published_at { Time.current }
    end

    trait :withdrawn do
      withdrawn_at { Time.current }
    end

    trait :in_person do
      type_of_meeting { :in_person }
    end

    trait :hidden do
      after :create do |meeting, evaluator|
        create(:moderation, hidden_at: Time.current, reportable: meeting, skip_injection: evaluator.skip_injection)
      end
    end

    trait :online do
      type_of_meeting { :online }
      online_meeting_url { "https://decidim.org" }
      latitude { nil }
      longitude { nil }
    end

    trait :hybrid do
      type_of_meeting { :hybrid }
      online_meeting_url { "https://decidim.org" }
    end

    trait :official do
      author { component.organization if component }
    end

    trait :not_official do
      author { create(:user, organization: component.organization, skip_injection:) if component }
    end

    trait :with_services do
      transient do
        services do
          nil
        end
      end

      after(:build) do |meeting, evaluator|
        meeting.services = evaluator.services || build_list(:service, 2, meeting:, skip_injection: evaluator.skip_injection)
      end
    end

    trait(:participant_author) { not_official }

    trait :closed do
      closing_report { generate_localized_title(:meeting_closing_report, skip_injection:) }
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
      registration_terms { generate_localized_title(:meeting_registration_terms, skip_injection:) }
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
      after(:create) do |meeting, evaluator|
        create(:moderation, reportable: meeting, hidden_at: 2.days.ago, skip_injection: evaluator.skip_injection)
      end
    end
  end

  factory :meeting_link, class: "Decidim::Meetings::MeetingLink" do
    meeting
    component
  end

  factory :registration, class: "Decidim::Meetings::Registration" do
    transient do
      skip_injection { false }
    end
    meeting
    user
  end

  factory :agenda, class: "Decidim::Meetings::Agenda" do
    transient do
      skip_injection { false }
    end

    meeting
    title { generate_localized_title(:meeting_agenda_title, skip_injection:) }
    visible { true }

    trait :with_agenda_items do
      after(:create) do |agenda, evaluator|
        create_list(:agenda_item, 2, :with_children, agenda:, skip_injection: evaluator.skip_injection)
      end
    end
  end

  factory :agenda_item, class: "Decidim::Meetings::AgendaItem" do
    transient do
      skip_injection { false }
    end

    agenda
    title { generate_localized_title(:meeting_agenda_item_title, skip_injection:) }
    description { generate_localized_description(:meeting_agenda_item_description, skip_injection:) }
    duration { 15 }
    position { 0 }

    trait :with_parent do
      parent { create(:agenda_item, agenda:, skip_injection:) }
    end

    trait :with_children do
      after(:create) do |agenda_item, evaluator|
        create_list(:agenda_item, 2, parent: agenda_item, agenda: evaluator.agenda, skip_injection: evaluator.skip_injection)
      end
    end
  end

  factory :invite, class: "Decidim::Meetings::Invite" do
    transient do
      skip_injection { false }
    end
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
    transient do
      skip_injection { false }
    end

    meeting
    title { generate_localized_title(:meeting_service_title, skip_injection:) }
    description { generate_localized_description(:meeting_service_description, skip_injection:) }
  end

  factory :poll, class: "Decidim::Meetings::Poll" do
    transient do
      skip_injection { false }
    end
    meeting
  end

  factory :meetings_poll_questionnaire, class: "Decidim::Meetings::Questionnaire" do
    transient do
      skip_injection { false }
    end
    questionnaire_for { build(:poll, skip_injection:) }
  end

  factory :meetings_poll_question, class: "Decidim::Meetings::Question" do
    transient do
      skip_injection { false }
      options { [] }
    end

    body { generate_localized_title(:meeting_poll_question_body, skip_injection:) }
    position { 0 }
    status { 0 }
    question_type { Decidim::Meetings::Question::QUESTION_TYPES.first }
    questionnaire factory: :meetings_poll_questionnaire
    response_options do
      Array.new(3).collect { build(:meetings_poll_response_option, question: nil, skip_injection:) }
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

  factory :meetings_poll_response, class: "Decidim::Meetings::Response" do
    transient do
      skip_injection { false }
    end
    questionnaire factory: :meetings_poll_questionnaire
    question { create(:meetings_poll_question, questionnaire:, skip_injection:) }
    user { create(:user, organization: questionnaire.questionnaire_for.organization, skip_injection:) }
  end

  factory :meetings_poll_response_option, class: "Decidim::Meetings::ResponseOption" do
    transient do
      skip_injection { false }
    end
    question { create(:meetings_poll_question, skip_injection:) }
    body { generate_localized_title }
  end

  factory :meetings_poll_response_choice, class: "Decidim::Meetings::ResponseChoice" do
    transient do
      skip_injection { false }
    end
    response factory: :meetings_poll_response
    response_option { create(:meetings_poll_response_option, question: response.question, skip_injection:) }
  end
end

# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :meeting_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :meetings).i18n_name }
    manifest_name :meetings
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
    private_meeting false
    transparent true
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

  factory :minutes, class: "Decidim::Meetings::Minutes" do
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    video_url { Faker::Internet.url }
    audio_url { Faker::Internet.url }
    visible true
    meeting
  end

  factory :questionnaire, class: Decidim::Meetings::Questionnaire do
    title { Decidim::Faker::Localized.sentence }
    description do
      Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.sentence(4)
      end
    end
    tos { Decidim::Faker::Localized.sentence(4) }
    questionnaire_type { "registration" }
    meeting
  end

  factory :questionnaire_question, class: Decidim::Meetings::QuestionnaireQuestion do
    transient do
      answer_options []
    end

    body { Decidim::Faker::Localized.sentence }
    mandatory false
    position 0
    question_type { Decidim::Meetings::QuestionnaireQuestion::TYPES.first }
    questionnaire

    before(:create) do |question, evaluator|
      evaluator.answer_options.each do |answer_option|
        question.answer_options.build(
          body: answer_option["body"],
          free_text: answer_option["free_text"]
        )
      end
    end
  end

  factory :questionnaire_answer, class: Decidim::Meetings::QuestionnaireAnswer do
    body { "Hi" }
    questionnaire
    question { create(:questionnaire_question, questionnaire: questionnaire) }
    user { create(:user, organization: questionnaire.meeting.organization) }
  end

  factory :questionnaire_answer_option, class: Decidim::Meetings::QuestionnaireAnswerOption do
    body { Decidim::Faker::Localized.sentence }
    question { create(:questionnaire_question) }
  end

  factory :questionnaire_answer_choice, class: Decidim::Meetings::QuestionnaireAnswerChoice do
    answer { create(:questionnaire_answer) }
    answer_option { create(:questionnaire_answer_option, question: answer.question) }
  end
end

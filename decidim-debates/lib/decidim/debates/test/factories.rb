# frozen_string_literal: true

require "decidim/components/namer"

def generate_localized_debate_title
  Decidim::Faker::Localized.localized { "<script>alert(\"TITLE\");</script> #{generate(:title)}" }
end

FactoryBot.define do
  factory :debate, class: "Decidim::Debates::Debate" do
    transient do
      skip_injection { false }
    end

    title { generate_localized_title(:debate_title, skip_injection:) }
    description { generate_localized_description(:debate_description, skip_injection:) }
    information_updates { generate_localized_description(:debate_information_updates, skip_injection:) }
    instructions { generate_localized_description(:debate_instructions, skip_injection:) }
    component { build(:debates_component, skip_injection:) }
    author { component.try(:organization) }
    comments_layout { "single_column" }
    deleted_at { nil }

    trait :with_endorsements do
      after :create do |post, evaluator|
        5.times.collect do
          create(:like,
                 resource: post,
                 skip_injection: evaluator.skip_injection,
                 author: build(:user, :confirmed, skip_injection: evaluator.skip_injection, organization: post.participatory_space.organization))
        end
      end
    end

    trait :open_ama do
      start_time { 1.day.ago }
      end_time { 1.day.from_now }
    end

    trait :participant_author do
      start_time { nil }
      end_time { nil }
      author do
        build(:user, organization: component.organization, skip_injection:) if component
      end
    end

    trait :official do
      author { component.try(:organization) }
    end

    trait :hidden do
      after :create do |debate, evaluator|
        create(:moderation, hidden_at: Time.current, reportable: debate, skip_injection: evaluator.skip_injection)
      end
    end

    trait :closed do
      closed_at { Time.current }
      conclusions { generate_localized_description(:debate_conclusions, skip_injection:) }
    end

    after(:build) do |debate|
      debate.title = Decidim::ContentProcessor.parse_with_processor(:hashtag, debate.title, current_organization: debate.organization).rewrite
      debate.description = Decidim::ContentProcessor.parse_with_processor(:hashtag, debate.description, current_organization: debate.organization).rewrite
    end
  end

  factory :debates_component, parent: :component do
    transient do
      skip_injection { false }
    end
    name { generate_component_name(participatory_space.organization.available_locales, :debates, skip_injection:) }
    manifest_name { :debates }
    participatory_space { create(:participatory_process, :with_steps, organization:, skip_injection:) }
    settings do
      {
        comments_enabled: true,
        comments_max_length: organization.comments_max_length
      }
    end

    trait :with_comments_blocked do
      step_settings do
        {
          participatory_space.active_step.id => {
            comments_blocked: true
          }
        }
      end
    end

    trait :with_creation_enabled do
      step_settings do
        {
          participatory_space.active_step.id => { creation_enabled: true }
        }
      end
    end

    trait :with_votes_enabled do
      # Needed for likes tests
    end

    trait :with_endorsements_blocked do
      step_settings do
        {
          participatory_space.active_step.id => {
            endorsements_enabled: true,
            endorsements_blocked: true
          }
        }
      end
    end

    trait :with_endorsements_enabled do
      step_settings do
        {
          participatory_space.active_step.id => { endorsements_enabled: true }
        }
      end
    end

    trait :with_endorsements_disabled do
      step_settings do
        {
          participatory_space.active_step.id => { endorsements_enabled: false }
        }
      end
    end
  end
end

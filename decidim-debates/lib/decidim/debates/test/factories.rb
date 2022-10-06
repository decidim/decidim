# frozen_string_literal: true

def generate_localized_debate_title
  Decidim::Faker::Localized.localized { "<script>alert(\"TITLE\");</script> #{generate(:title)}" }
end

FactoryBot.define do
  factory :debate, class: "Decidim::Debates::Debate" do
    transient do
      skip_injection { false }
    end

    title do
      if skip_injection
        Decidim::Faker::Localized.localized { generate(:title) }
      else
        Decidim::Faker::Localized.localized { "<script>alert(\"TITLE\");</script> #{generate(:title)}" }
      end
    end
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_debate_title } }
    information_updates { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_debate_title } }
    instructions { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_debate_title } }
    component { build(:component, manifest_name: "debates") }
    author { component.try(:organization) }

    trait :open_ama do
      start_time { 1.day.ago }
      end_time { 1.day.from_now }
    end

    trait :participant_author do
      start_time { nil }
      end_time { nil }
      author do
        build(:user, organization: component.organization) if component
      end
    end

    trait :official do
      author { component.try(:organization) }
    end

    trait :user_group_author do
      author do
        create(:user, organization: component.organization) if component
      end

      user_group do
        create(:user_group, :verified, organization: component.organization, users: [author]) if component
      end
    end

    trait :closed do
      closed_at { Time.current }
      conclusions { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_debate_title } }
    end

    after(:build) do |debate|
      debate.title = Decidim::ContentProcessor.parse_with_processor(:hashtag, debate.title, current_organization: debate.organization).rewrite
      debate.description = Decidim::ContentProcessor.parse_with_processor(:hashtag, debate.description, current_organization: debate.organization).rewrite
    end
  end

  factory :debates_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :debates).i18n_name }
    manifest_name { :debates }
    participatory_space { create(:participatory_process, :with_steps, organization:) }
    settings do
      {
        comments_enabled: true
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
      # Needed for endorsements tests
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

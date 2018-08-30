# frozen_string_literal: true

FactoryBot.define do
  factory :debate, class: "Decidim::Debates::Debate" do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    information_updates { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    instructions { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    start_time { 1.day.from_now }
    end_time { start_time.advance(hours: 2) }
    component { build(:component, manifest_name: "debates") }

    trait :open_ama do
      start_time { 1.day.ago }
      end_time { 1.day.from_now }
    end

    trait :with_author do
      author do
        build(:user, organization: component.organization) if component
      end
    end

    trait :with_user_group_author do
      author do
        build(:user, organization: component.organization) if component
      end
      user_group do
        build(:user_group, :verified, organization: component.organization, users: [author]) if component
      end
    end
  end

  factory :debates_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :debates).i18n_name }
    manifest_name { :debates }
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }
    settings do
      {
        comments_enabled: true
      }
    end

    trait :with_creation_enabled do
      step_settings do
        {
          participatory_space.active_step.id => { creation_enabled: true }
        }
      end
    end
  end
end

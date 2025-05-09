# frozen_string_literal: true

require "decidim/components/namer"

FactoryBot.define do
  factory :dummy_component, parent: :component do
    transient do
      skip_injection { false }
    end
    name { generate_component_name(participatory_space.organization.available_locales, :surveys, skip_injection:) }
    manifest_name { :dummy }
  end

  factory :dummy_resource, class: "Decidim::Dev::DummyResource" do
    transient do
      skip_injection { false }
      users { nil }
    end
    title { generate_localized_title(:dummy_resource_title, skip_injection:) }
    component { create(:dummy_component, skip_injection:) }
    author { create(:user, :confirmed, organization: component.organization, skip_injection:) }
    scope { create(:scope, organization: component.organization, skip_injection:) }

    trait :published do
      published_at { Time.current }
    end

    trait :with_endorsements do
      after :create do |resource, evaluator|
        5.times.collect do
          create(:like, resource:, skip_injection: evaluator.skip_injection,
                               author: build(:user, organization: resource.component.organization, skip_injection: evaluator.skip_injection))
        end
      end
    end

    trait :moderated do
      after(:create) do |resource, evaluator|
        create(:moderation, reportable: resource, hidden_at: 2.days.ago, skip_injection: evaluator.skip_injection)
      end
    end
  end

  factory :nested_dummy_resource, class: "Decidim::Dev::NestedDummyResource" do
    transient do
      skip_injection { false }
    end
    title { generate(:name) }
    dummy_resource { create(:dummy_resource) }
  end

  factory :coauthorable_dummy_resource, class: "Decidim::Dev::CoauthorableDummyResource" do
    transient do
      skip_injection { false }
      authors_list { [create(:user, organization: component.organization, skip_injection:)] }
    end
    title { generate(:name) }
    component { create(:component, manifest_name: "dummy") }

    after :build do |resource, evaluator|
      evaluator.authors_list.each do |coauthor|
        resource.coauthorships << build(:coauthorship, author: coauthor, coauthorable: resource, organization: evaluator.component.organization,
                                                       skip_injection: evaluator.skip_injection)
      end
    end
  end
end

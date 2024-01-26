# frozen_string_literal: true

require "decidim/components/namer"

FactoryBot.define do
  factory :dummy_component, parent: :component do
    transient do
      skip_injection { false }
    end
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :surveys).i18n_name }
    manifest_name { :dummy }
  end

  factory :dummy_resource, class: "Decidim::Dev::DummyResource" do
    transient do
      skip_injection { false }
      users { nil }
      # user_groups correspondence to users is by sorting order
      user_groups { [] }
    end
    title { Decidim::Faker::Localized.localized { generate(:name) } }
    component { create(:dummy_component) }
    author { create(:user, :confirmed, organization: component.organization) }
    scope { create(:scope, organization: component.organization) }

    trait :published do
      published_at { Time.current }
    end

    trait :with_endorsements do
      after :create do |resource|
        5.times.collect do
          create(:endorsement, resource:, author: build(:user, organization: resource.component.organization))
        end
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
    title { generate(:name) }
    component { create(:component, manifest_name: "dummy") }

    transient do
      skip_injection { false }
      authors_list { [create(:user, organization: component.organization)] }
    end

    after :build do |resource, evaluator|
      evaluator.authors_list.each do |coauthor|
        resource.coauthorships << if coauthor.is_a?(Decidim::UserGroup)
                                    build(:coauthorship, author: coauthor.users.first, user_group: coauthor, coauthorable: resource, organization: evaluator.component.organization)
                                  else
                                    build(:coauthorship, author: coauthor, coauthorable: resource, organization: evaluator.component.organization)
                                  end
      end
    end
  end
end

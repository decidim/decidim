# frozen_string_literal: true
require "decidim/faker/localized"
require "decidim/dev"

FactoryGirl.define do
  factory :budget_feature, class: Decidim::Feature do
    name { Decidim::Features::Namer.new(participatory_process.organization.available_locales, :budgets).i18n_name }
    manifest_name :budgets
    participatory_process

    trait :with_total_budget do
      transient do
        total_budget 100_000_000
      end

      settings do
        {
          total_budget: total_budget
        }
      end
    end
  end

  factory :project, class: Decidim::Budgets::Project do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    short_description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    budget { Faker::Number.number(8) }
    feature
  end

  factory :order, class: Decidim::Budgets::Order do
    user
    feature
  end

  factory :line_item, class: Decidim::Budgets::LineItem do
    order
    project { build(:project, feature: order.feature) }
  end
end

# frozen_string_literal: true
require "decidim/faker/localized"
require "decidim/dev"

FactoryGirl.define do
  factory :budget_feature, parent: :feature do
    name { Decidim::Features::Namer.new(participatory_process.organization.available_locales, :budgets).i18n_name }
    manifest_name :budgets
    participatory_process

    trait :with_total_budget_and_vote_threshold_percent do
      transient do
        total_budget 100_000_000
        vote_threshold_percent 70
      end

      settings do
        {
          total_budget: total_budget,
          vote_threshold_percent: vote_threshold_percent
        }
      end
    end

    trait :with_votes_disabled do
      step_settings do
        {
          participatory_process.active_step.id => {
            votes_enabled: false
          }
        }
      end
    end

    trait :with_show_votes_enabled do
      step_settings do
        {
          participatory_process.active_step.id => {
            show_votes: true
          }
        }
      end
    end
  end

  factory :project, class: Decidim::Budgets::Project do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    budget { Faker::Number.number(8) }
    feature { create(:budget_feature) }
  end

  factory :order, class: Decidim::Budgets::Order do
    feature { create(:budget_feature) }
    user { create(:user, organization: feature.organization) }
  end

  factory :line_item, class: Decidim::Budgets::LineItem do
    order
    project { create(:project, feature: order.feature) }
  end
end

# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :budget_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :budgets).i18n_name }
    manifest_name { :budgets }
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }

    trait :with_total_budget_and_vote_threshold_percent do
      transient do
        total_budget { 100_000_000 }
        vote_threshold_percent { 70 }
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
          participatory_space.active_step.id => {
            votes_enabled: false
          }
        }
      end
    end

    trait :with_show_votes_enabled do
      step_settings do
        {
          participatory_space.active_step.id => {
            show_votes: true
          }
        }
      end
    end
  end

  factory :project, class: "Decidim::Budgets::Project" do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    budget { Faker::Number.number(8) }
    component { create(:budget_component) }
  end

  factory :order, class: "Decidim::Budgets::Order" do
    component { create(:budget_component) }
    user { create(:user, organization: component.organization) }
  end

  factory :line_item, class: "Decidim::Budgets::LineItem" do
    order
    project { create(:project, component: order.component) }
  end
end

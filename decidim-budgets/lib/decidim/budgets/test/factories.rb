# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :budgets_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :budgets).i18n_name }
    manifest_name { :budgets }
    participatory_space { create(:participatory_process, :with_steps, organization:) }

    trait :with_geocoding_enabled do
      settings do
        {
          geocoding_enabled: true
        }
      end
    end

    trait :with_vote_threshold_percent do
      transient do
        vote_rule_threshold_percent_enabled { true }
        vote_rule_minimum_budget_projects_enabled { false }
        vote_rule_projects_enabled { false }
        vote_threshold_percent { 70 }
      end

      settings do
        {
          vote_rule_threshold_percent_enabled:,
          vote_rule_minimum_budget_projects_enabled:,
          vote_rule_selected_projects_enabled: vote_rule_projects_enabled,
          vote_threshold_percent:
        }
      end
    end

    trait :with_minimum_budget_projects do
      transient do
        vote_rule_threshold_percent_enabled { false }
        vote_rule_minimum_budget_projects_enabled { true }
        vote_rule_projects_enabled { false }
        vote_minimum_budget_projects_number { 3 }
      end

      settings do
        {
          vote_rule_threshold_percent_enabled:,
          vote_rule_minimum_budget_projects_enabled:,
          vote_rule_selected_projects_enabled: vote_rule_projects_enabled,
          vote_minimum_budget_projects_number:
        }
      end
    end

    trait :with_budget_projects_range do
      transient do
        vote_rule_threshold_percent_enabled { false }
        vote_rule_minimum_budget_projects_enabled { false }
        vote_rule_projects_enabled { true }
        vote_minimum_budget_projects_number { 3 }
        vote_maximum_budget_projects_number { 6 }
      end

      settings do
        {
          vote_rule_threshold_percent_enabled:,
          vote_rule_minimum_budget_projects_enabled:,
          vote_rule_selected_projects_enabled: vote_rule_projects_enabled,
          vote_selected_projects_minimum: vote_minimum_budget_projects_number,
          vote_selected_projects_maximum: vote_maximum_budget_projects_number
        }
      end
    end

    trait :with_votes_disabled do
      step_settings do
        {
          participatory_space.active_step.id => {
            votes: :disabled
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

    trait :with_voting_finished do
      step_settings do
        {
          participatory_space.active_step.id => {
            votes: :finished,
            show_votes: true
          }
        }
      end
    end
  end

  factory :budget, class: "Decidim::Budgets::Budget" do
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    total_budget { 100_000_000 }
    component { create(:budgets_component) }

    trait :with_projects do
      transient do
        projects_number { 2 }
      end

      after(:create) do |budget, evaluator|
        create_list(:project, evaluator.projects_number, budget:)
      end
    end
  end

  factory :project, class: "Decidim::Budgets::Project" do
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    address { "#{Faker::Address.street_name}, #{Faker::Address.city}" }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    budget_amount { Faker::Number.number(digits: 8) }
    budget { create(:budget) }

    trait :selected do
      selected_at { Time.current }
    end

    trait :with_photos do
      transient do
        photos_number { 2 }
      end

      after :create do |project, evaluator|
        project.attachments = create_list(:attachment, evaluator.photos_number, :with_image, attached_to: project)
      end
    end
  end

  factory :order, class: "Decidim::Budgets::Order" do
    budget { create(:budget) }
    user { create(:user, organization: component.organization) }

    trait :with_projects do
      transient do
        projects_number { 2 }
      end

      after(:create) do |order, evaluator|
        project_budget = (order.maximum_budget / evaluator.projects_number).to_i
        order.projects << create_list(:project, evaluator.projects_number, budget_amount: project_budget, budget: order.budget)
        order.save!
      end
    end
  end

  factory :line_item, class: "Decidim::Budgets::LineItem" do
    order
    project { create(:project, budget: order.budget) }
  end
end

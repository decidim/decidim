# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :sortition_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :sortitions).i18n_name }
    manifest_name { :sortitions }
    participatory_space { create(:participatory_process, :with_steps, organization:) }
  end

  factory :sortition, class: "Decidim::Sortitions::Sortition" do
    component { create(:sortition_component) }
    decidim_proposals_component { create(:proposal_component, organization: component.organization) }

    title { generate_localized_title }
    author do
      create(:user, :admin, organization: component.organization) if component
    end

    dice { Faker::Number.between(from: 1, to: 6).to_i }
    target_items { Faker::Number.between(from: 1, to: 5).to_i }
    request_timestamp { Time.now.utc }
    witnesses { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    additional_info { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    selected_proposals { create_list(:proposal, target_items, component: decidim_proposals_component).pluck(:id) }
    candidate_proposals { selected_proposals }

    trait :cancelled do
      cancelled_on { Time.now.utc }
      cancel_reason { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
      cancelled_by_user { create(:user, :admin, organization: component.organization) if component }
    end
  end
end

# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/faker/localized"
require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :sortition_component, parent: :component do
    transient do
      skip_injection { false }
    end
    name { generate_component_name(participatory_space.organization.available_locales, :sortitions, skip_injection:) }
    manifest_name { :sortitions }
    participatory_space { create(:participatory_process, :with_steps, organization:, skip_injection:) }
  end

  factory :sortition, class: "Decidim::Sortitions::Sortition" do
    transient do
      skip_injection { false }
    end
    component { create(:sortition_component, skip_injection:) }
    decidim_proposals_component { create(:proposal_component, organization: component.organization, skip_injection:) }

    title { generate_localized_title(:sortition_title, skip_injection:) }
    author do
      create(:user, :admin, organization: component.organization) if component
    end

    dice { Faker::Number.between(from: 1, to: 6).to_i }
    target_items { Faker::Number.between(from: 1, to: 5).to_i }
    request_timestamp { Time.now.utc }
    witnesses { generate_localized_description(:sortition_witnesses, skip_injection:) }
    additional_info { generate_localized_description(:sortition_additional_info, skip_injection:) }
    selected_proposals { create_list(:proposal, target_items, component: decidim_proposals_component, skip_injection:).pluck(:id) }
    candidate_proposals { selected_proposals }

    trait :cancelled do
      cancelled_on { Time.now.utc }
      cancel_reason { generate_localized_description(:sortition_cancel_reason, skip_injection:) }
      cancelled_by_user { create(:user, :admin, organization: component.organization, skip_injection:) if component }
    end
  end
end

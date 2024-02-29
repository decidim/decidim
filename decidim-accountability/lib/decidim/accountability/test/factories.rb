# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :accountability_component, parent: :component do
    transient do
      skip_injection { false }
    end
    name { generate_component_name(participatory_space.organization.available_locales, :accountability, skip_injection: skip_injection) }
    manifest_name { :accountability }
    participatory_space { create(:participatory_process, :with_steps, organization: organization, skip_injection: skip_injection) }
    settings do
      {
        intro: generate_localized_description(:accountability_component_intro, skip_injection: skip_injection),
        categories_label: generate_localized_word(:accountability_component_categories_label, skip_injection: skip_injection),
        subcategories_label: generate_localized_word(:accountability_component_subcategories_label, skip_injection: skip_injection),
        heading_parent_level_results: generate_localized_word(:accountability_component_heading_parent_level_results, skip_injection: skip_injection),
        heading_leaf_level_results: generate_localized_word(:accountability_component_heading_leaf_level_results, skip_injection: skip_injection),
        scopes_enabled: true,
        scope_id: participatory_space.scope&.id
      }
    end
  end

  factory :status, class: "Decidim::Accountability::Status" do
    transient do
      skip_injection { false }
    end
    component { create(:accountability_component, skip_injection: skip_injection) }
    sequence(:key) { |n| "status_#{n}" }
    name { generate_localized_word(:status_name, skip_injection: skip_injection) }
    description { generate_localized_word(:status_description, skip_injection: skip_injection) }
    progress { rand(1..100) }
  end

  factory :result, class: "Decidim::Accountability::Result" do
    transient do
      skip_injection { false }
    end
    component { create(:accountability_component, skip_injection: skip_injection) }
    title { generate_localized_title(:result_title, skip_injection: skip_injection) }
    description { generate_localized_description(:result_description, skip_injection: skip_injection) }
    start_date { "12/7/2017" }
    end_date { "30/9/2017" }
    status { create :status, component: component, skip_injection: skip_injection }
    progress { rand(1..100) }
  end

  factory :timeline_entry, class: "Decidim::Accountability::TimelineEntry" do
    transient do
      skip_injection { false }
    end
    result { create(:result, skip_injection: skip_injection) }
    entry_date { "12/7/2017" }
    title { generate_localized_title(:timeline_entry_title, skip_injection: skip_injection) }
    description { generate_localized_title(:timeline_entry_description, skip_injection: skip_injection) }
  end
end

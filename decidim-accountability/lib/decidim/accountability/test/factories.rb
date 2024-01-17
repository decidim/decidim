# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/faker/localized"
require "decidim/dev"

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :accountability_component, parent: :component do
    transient do
      skip_injection { false }
    end
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :accountability).i18n_name }
    manifest_name { :accountability }
    participatory_space { create(:participatory_process, :with_steps, skip_injection:, organization:) }
    settings do
      {
        intro: generate_localized_description(:accountability_component_intro, skip_injection:),
        categories_label: generate_localized_word(:accountability_component_categories_label, skip_injection:),
        subcategories_label: generate_localized_word(:accountability_component_subcategories_label, skip_injection:),
        heading_parent_level_results: generate_localized_word(:accountability_component_heading_parent_level_results, skip_injection:),
        heading_leaf_level_results: generate_localized_word(:accountability_component_heading_leaf_level_results, skip_injection:),
        scopes_enabled: true,
        scope_id: participatory_space.scope&.id
      }
    end
  end

  factory :status, class: "Decidim::Accountability::Status" do
    transient do
      skip_injection { false }
    end
    component { create(:accountability_component) }
    sequence(:key) { |n| "status_#{n}" }
    name { generate_localized_word(:status_name, skip_injection:) }
    description { generate_localized_word(:status_description, skip_injection:) }
    progress { rand(1..100) }
  end

  factory :result, class: "Decidim::Accountability::Result" do
    transient do
      skip_injection { false }
    end
    component { create(:accountability_component) }
    title { generate_localized_title(:result_title, skip_injection:) }
    description { generate_localized_description(:result_description, skip_injection:) }
    start_date { "12/7/2017" }
    end_date { "30/9/2017" }
    status { create :status, component: }
    progress { rand(1..100) }
  end

  factory :timeline_entry, class: "Decidim::Accountability::TimelineEntry" do
    transient do
      skip_injection { false }
    end
    result { create(:result) }
    entry_date { "12/7/2017" }
    title { generate_localized_title(:timeline_entry_title, skip_injection:) }
    description { generate_localized_title(:timeline_entry_description, skip_injection:) }
  end
end

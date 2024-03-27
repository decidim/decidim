# frozen_string_literal: true

FactoryBot.define do
  factory :dummy_component, parent: :component do
    transient do
      skip_injection { false }
    end

    name { generate_component_name(participatory_space.organization.available_locales, :dummy, skip_injection: skip_injection) }
    manifest_name { :dummy }
  end
end

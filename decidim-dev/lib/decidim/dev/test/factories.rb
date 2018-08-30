# frozen_string_literal: true

FactoryBot.define do
  factory :dummy_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :surveys).i18n_name }
    manifest_name { :dummy }
  end
end

# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :post_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :blogs).i18n_name }
    manifest_name { :blogs }
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }
  end

  factory :post, class: "Decidim::Blogs::Post" do
    title { generate_localized_title }
    body { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    component { build(:component, manifest_name: "blogs") }
    author { build(:user, :confirmed, organization: component.organization) }
  end
end

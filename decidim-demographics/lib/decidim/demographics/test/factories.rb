# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :demographics_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :demographics).i18n_name }
    manifest_name { :demographics }
    participatory_space { create(:participatory_process, :with_steps) }
  end

  factory :demographic, class: "Decidim::Demographics::Demographic" do
    user
    organization
    data do
      {
        age: Decidim::Demographics::Demographic::AGE_GROUPS.sample,
        gender: Decidim::Demographics::Demographic::AVAILABLE_GENDERS.sample,
        nationalities: Decidim::Demographics::Demographic::PROFESSIONAL_CATEGORIES.sample(Random.rand(1...3)),
        residences: Decidim::Demographics::Demographic::MEMBER_COUNTRIES.sample(Random.rand(1...2)),
        living_condition: Decidim::Demographics::Demographic::LIVING_CONDITIONS.sample,
        current_occupations: Decidim::Demographics::Demographic::PROFESSIONAL_CATEGORIES.sample(Random.rand(1...2)),
        education_age_stop: Decidim::Demographics::Demographic::EDUCATION_OPTIONS.sample,
        newsletter_subscribe: true,
        attended_before: Decidim::Demographics::Demographic::ATTENDED_BEFORE.sample,
        newsletter_sign_in: true
      }
    end
  end
end

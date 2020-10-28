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
        background: Decidim::Demographics::Demographic::PROFESSIONAL_CATEGORIES.sample,
        gender: Decidim::Demographics::Demographic::AVAILABLE_GENDERS.sample,
        nationality: Decidim::Demographics::Demographic::PROFESSIONAL_CATEGORIES.sample(Random.rand(1...3)),
        postal_code: Faker::Address.zip_code
      }
    end
  end

  factory :encrypted_demographic, class: "Decidim::Demographics::Demographic" do
    user
    organization
    data do
      {
        age: Decidim::AttributeEncryptor.encrypt(Decidim::Demographics::Demographic::AGE_GROUPS.sample),
        background: Decidim::AttributeEncryptor.encrypt(Decidim::Demographics::Demographic::PROFESSIONAL_CATEGORIES.sample),
        gender: Decidim::AttributeEncryptor.encrypt(Decidim::Demographics::Demographic::AVAILABLE_GENDERS.sample),
        nationality: Decidim::AttributeEncryptor.encrypt(Decidim::Demographics::Demographic::PROFESSIONAL_CATEGORIES.sample(Random.rand(1...3))),
        postal_code: Decidim::AttributeEncryptor.encrypt(Faker::Address.zip_code)
      }
    end
  end
end

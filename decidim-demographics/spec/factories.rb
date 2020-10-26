# frozen_string_literal: true

require "decidim/demographics/test/factories"

FactoryBot.define do
  factory :data, class: OpenStruct do
    send :'@type', "data"
    age { Decidim::Demographics::Demographic::AGE_GROUPS.sample }
    background { Decidim::Demographics::Demographic::PROFESSIONAL_CATEGORIES.sample }
    gender { Decidim::Demographics::Demographic::AVAILABLE_GENDERS.sample }
    nationality { Decidim::Demographics::Demographic::PROFESSIONAL_CATEGORIES.sample(Random.rand(1...3)) }
    postal_code { Faker::Address.zip_code }
  end

  factory :demographic, class: "Decidim::Demographics::Demographic" do
    user
    organization
    data
  end
end

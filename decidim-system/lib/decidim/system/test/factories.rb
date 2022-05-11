# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :admin, class: "Decidim::System::Admin" do
    sequence(:email) { |n| "admin#{n}@citizen.corp" }
    password { "decidim123456" }
    password_confirmation { "decidim123456" }
  end
end

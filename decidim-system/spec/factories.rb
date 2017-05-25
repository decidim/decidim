# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryGirl.define do
  factory :admin, class: Decidim::System::Admin do
    sequence(:email)      { |n| "admin#{n}@citizen.corp" }
    password              "password1234"
    password_confirmation "password1234"
  end
end

# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/dev"

FactoryBot.define do
  factory :csv_datum, class: "Decidim::Verifications::CsvDatum" do
    email { generate(:email) }
    organization
  end
end

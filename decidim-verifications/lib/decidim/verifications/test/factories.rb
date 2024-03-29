# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/dev"

FactoryBot.define do
  factory :csv_datum, class: "Decidim::Verifications::CsvDatum" do
    transient do
      skip_injection { false }
    end
    email { generate(:email) }
    organization
  end

  factory :conflict, class: "Decidim::Verifications::Conflict" do
    transient do
      skip_injection { false }
    end
    current_user { create(:user, skip_injection:) }
    managed_user { create(:user, managed: true, organization: current_user.organization, skip_injection:) }
    unique_id { "12345678X" }
    times { 1 }
  end
end

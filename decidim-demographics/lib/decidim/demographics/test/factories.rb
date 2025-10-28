# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/faker/localized"
require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :demographic, class: "Decidim::Demographics::Demographic" do
    transient do
      skip_injection { false }
    end

    organization
  end
end

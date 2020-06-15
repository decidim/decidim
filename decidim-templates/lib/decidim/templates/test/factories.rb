# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.define do
  factory :template, class: "Decidim::Templates::Template" do
    organization
    templatable { build(:dummy_resource) }

    factory :questionnaire_template do
      templatable { build(:questionnaire) }
    end
  end
end

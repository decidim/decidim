# frozen_string_literal: true
require "decidim/core/test/factories"
require "decidim/comments/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :debate, class: Decidim::Debates::Debate do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    instructions { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    start_time { 1.day.from_now }
    end_time { start_time.advance(hours: 2) }
    feature { build(:feature, manifest_name: "debates") }
  end

  factory :debates_feature, parent: :feature do
    name { Decidim::Features::Namer.new(participatory_space.organization.available_locales, :debates).i18n_name }
    manifest_name :debates
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }
    settings do
      {
        comments_enabled: true
      }
    end
  end
end

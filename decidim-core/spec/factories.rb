# coding: utf-8
FactoryGirl.define do
  factory :organization, class: Decidim::Organization do
    sequence(:name) { |n| "Citizen Corp ##{n}" }
    sequence(:host) { |n| "#{n}.citizen.corp" }
    description     "Description"
  end

  factory :participatory_process, class: Decidim::ParticipatoryProcess do
    sequence(:title) { |n| { dev: "Participatory Process ##{n}" } }
    sequence(:slug) { |n| { dev: "participatory-process-#{n}" } }
    subtitle          dev: "Subtitle"
    short_description dev: "<p>Short description</p>"
    description       dev: "<p>Description</p>"
    hero_image { Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), "..", "..", "decidim-dev", "spec", "support", "city.jpeg")) }
    banner_image { Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), "..", "..", "decidim-dev", "spec", "support", "city2.jpeg")) }
    organization

    trait :promoted do
      promoted true
    end
  end

  factory :participatory_process_step, class: Decidim::ParticipatoryProcessStep do
    sequence(:title) { |n| { dev: "Participatory Process Step ##{n}" } }
    short_description dev: "<p>Short description</p>"
    description       dev: "<p>Description</p>"
    start_date 1.month.ago.at_midnight
    end_date 2.month.from_now.at_midnight
    position nil
    participatory_process

    trait :active do
      active true
    end
  end

  factory :user, class: Decidim::User do
    sequence(:email)      { |n| "user#{n}@citizen.corp" }
    password              "password1234"
    password_confirmation "password1234"
    name                  "Responsible Citizen"
    organization
    locale                "dev"
    tos_agreement         "1"

    trait :confirmed do
      confirmed_at { Time.current }
    end

    trait :admin do
      roles ["admin"]
    end

    trait :moderator do
      roles ["moderator"]
    end

    trait :official do
      roles ["official"]
    end
  end
end

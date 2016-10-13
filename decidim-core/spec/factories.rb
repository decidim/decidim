FactoryGirl.define do
  factory :organization, class: Decidim::Organization do
    sequence(:name) { |n| "Citizen Corp ##{n}" }
    sequence(:host) { |n| "#{n}.citizen.corp" }
    description     "Description"
  end

  factory :process, class: Decidim::ParticipatoryProcess do
    sequence(:title) { |n| { en: "Participatory Process ##{n}", ca: "Procés participatiu ##{n}", es: "Proceso participativo ##{n}" } }
    sequence(:slug) { |n| { en: "participatory-process-#{n}" } }
    subtitle          en: "Subtitle", ca: "Subtítol", es: "Subtítulo"
    short_description en: "<p>Short description</p>", ca: "<p>Descripció curta</p>", es: "<p>Descripción corta</p>"
    description       en: "<p>Description</p>", ca: "<p>Descripció</p>", es: "<p>Descripción</p>"
    hero_image { Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), "..", "..", "decidim-dev", "spec", "support", "city.jpeg")) }
    banner_image { Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), "..", "..", "decidim-dev", "spec", "support", "city2.jpeg")) }
    organization
  end

  factory :user, class: Decidim::User do
    sequence(:email)      { |n| "user#{n}@citizen.corp" }
    password              "password1234"
    password_confirmation "password1234"
    name                  "Responsible Citizen"
    organization
    locale                "en"
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

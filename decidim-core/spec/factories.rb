FactoryGirl.define do
  factory :organization, class: Decidim::Organization do
    sequence(:name) { |n| "Citizen Corp ##{n}" }
    sequence(:host) { |n| "#{n}.citizen.corp" }
  end

  factory :user, class: Decidim::User do
    sequence(:email)      { |n| "user#{n}@citizen.corp" }
    password              "password1234"
    password_confirmation "password1234"
    organization

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

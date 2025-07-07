# frozen_string_literal: true

FactoryBot.define do
  sequence :api_key do |n|
    "api_user_#{n}"
  end

  factory :api_user, class: "Decidim::Api::ApiUser" do
    transient do
      api_secret { "decidim123456789" }
    end

    name { generate(:name) }
    api_key { generate(:api_key) }
    nickname { generate(:nickname) }
    organization
    locale { organization.default_locale }
    tos_agreement { "1" }
    confirmation_sent_at { Time.current }
    accepted_tos_version { organization.tos_version }
    admin { true }
    admin_terms_accepted_at { Time.current }
    notifications_sending_frequency { "none" }
    email_on_moderations { false }
    password_updated_at { Time.current }
    previous_passwords { [] }
    extended_data { {} }

    after(:build) do |user, evaluator|
      user.api_secret = evaluator.api_secret
    end
  end
end

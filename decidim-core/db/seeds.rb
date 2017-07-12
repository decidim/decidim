# frozen_string_literal: true

if !Rails.env.production? || ENV["SEED"]
  require "decidim/faker/localized"

  organization = Decidim::Organization.first || Decidim::Organization.create!(
    name: Faker::Company.name,
    twitter_handler: Faker::Hipster.word,
    facebook_handler: Faker::Hipster.word,
    instagram_handler: Faker::Hipster.word,
    youtube_handler: Faker::Hipster.word,
    github_handler: Faker::Hipster.word,
    host: ENV["DECIDIM_HOST"] || "localhost",
    welcome_text: Decidim::Faker::Localized.sentence(5),
    description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
      Decidim::Faker::Localized.sentence(15)
    end,
    homepage_image: File.new(File.join(__dir__, "seeds", "homepage_image.jpg")),
    default_locale: I18n.default_locale,
    available_locales: [:en, :ca, :es],
    reference_prefix: Faker::Name.suffix
  )

  3.times.each do
    Decidim::Scope.create!(
      name: Faker::Address.unique.state,
      organization: organization
    )
  end

  Decidim::User.find_or_initialize_by(email: "admin@example.org").update!(
    name: Faker::Name.name,
    password: "decidim123456",
    password_confirmation: "decidim123456",
    organization: organization,
    confirmed_at: Time.current,
    locale: I18n.default_locale,
    admin: true,
    tos_agreement: true,
    comments_notifications: true,
    replies_notifications: true
  )

  Decidim::User.find_or_initialize_by(email: "user@example.org").update!(
    name: Faker::Name.name,
    password: "decidim123456",
    password_confirmation: "decidim123456",
    confirmed_at: Time.current,
    locale: I18n.default_locale,
    organization: organization,
    tos_agreement: true,
    comments_notifications: true,
    replies_notifications: true
  )

  Decidim::User.find_each do |user|
    [nil, Time.current].each do |verified_at|
      user_group = Decidim::UserGroup.create!(
        name: Faker::Company.unique.name,
        document_number: Faker::Number.number(10),
        phone: Faker::PhoneNumber.phone_number,
        verified_at: verified_at,
        decidim_organization_id: user.organization.id
      )

      Decidim::UserGroupMembership.create!(
        user: user,
        user_group: user_group
      )
    end
  end
end

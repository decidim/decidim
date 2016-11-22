# frozen_string_literal: true
if !Rails.env.production? || ENV["SEED"]
  require "decidim/faker/localized"

  puts "Creating Decidim::Core seeds..."

  staging_organization = Decidim::Organization.create!(
    name: Faker::Company.name,
    host: ENV["DECIDIM_HOST"] || "localhost",
    default_locale: I18n.default_locale,
    available_locales: Decidim.available_locales
  )

  Decidim::User.create!(
    name: Faker::Name.name,
    email: "admin@decidim.org",
    password: "decidim123456",
    password_confirmation: "decidim123456",
    organization: staging_organization,
    confirmed_at: Time.current,
    locale: I18n.default_locale,
    roles: ["admin"],
    tos_agreement: true
  )

  Decidim::User.create!(
    name: Faker::Name.name,
    email: "user@decidim.org",
    password: "decidim123456",
    password_confirmation: "decidim123456",
    confirmed_at: Time.current,
    locale: I18n.default_locale,
    organization: staging_organization,
    tos_agreement: true
  )

  participatory_process1 = Decidim::ParticipatoryProcess.create!(
    title: Decidim::Faker::Localized.sentence(5),
    slug: Faker::Internet.slug(nil, "-"),
    subtitle: Decidim::Faker::Localized.sentence(2),
    hashtag: "##{Faker::Lorem.word}",
    short_description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
      Decidim::Faker::Localized.sentence(3)
    end,
    description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
      Decidim::Faker::Localized.paragraph(3)
    end,
    hero_image: File.new(File.join(File.dirname(__FILE__), "seeds", "city.jpeg")),
    banner_image: File.new(File.join(File.dirname(__FILE__), "seeds", "city2.jpeg")),
    promoted: true,
    published_at: 2.weeks.ago,
    organization: staging_organization
  )

  Decidim::ParticipatoryProcess.create!(
    title: Decidim::Faker::Localized.sentence(5),
    slug: Faker::Internet.slug(nil, "-"),
    subtitle: Decidim::Faker::Localized.sentence(2),
    hashtag: "##{Faker::Lorem.word}",
    short_description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
      Decidim::Faker::Localized.sentence(3)
    end,
    description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
      Decidim::Faker::Localized.paragraph(3)
    end,
    hero_image: File.new(File.join(File.dirname(__FILE__), "seeds", "city2.jpeg")),
    banner_image: File.new(File.join(File.dirname(__FILE__), "seeds", "city3.jpeg")),
    published_at: 1.week.ago,
    organization: staging_organization
  )

  Decidim::ParticipatoryProcess.create!(
    title: Decidim::Faker::Localized.sentence(5),
    slug: Faker::Internet.slug(nil, "-"),
    subtitle: Decidim::Faker::Localized.sentence(2),
    hashtag: "##{Faker::Lorem.word}",
    short_description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
      Decidim::Faker::Localized.sentence(3)
    end,
    description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
      Decidim::Faker::Localized.paragraph(3)
    end,
    hero_image: File.new(File.join(File.dirname(__FILE__), "seeds", "city3.jpeg")),
    banner_image: File.new(File.join(File.dirname(__FILE__), "seeds", "city2.jpeg")),
    organization: staging_organization
  )

  Decidim::ParticipatoryProcessStep.create!(
    title: Decidim::Faker::Localized.sentence(5),
    short_description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
      Decidim::Faker::Localized.sentence(3)
    end,
    description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
      Decidim::Faker::Localized.paragraph(3)
    end,
    active: true,
    start_date: 1.month.ago.at_midnight,
    end_date: 2.months.from_now.at_midnight,
    participatory_process: participatory_process1
  )

  Decidim::ParticipatoryProcessStep.create!(
    title: Decidim::Faker::Localized.sentence(5),
    short_description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
      Decidim::Faker::Localized.sentence(3)
    end,
    description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
      Decidim::Faker::Localized.paragraph(3)
    end,
    start_date: 2.months.from_now.at_midnight,
    end_date: 3.months.from_now.at_midnight,
    participatory_process: participatory_process1
  )
end

# frozen_string_literal: true
if !Rails.env.production? || ENV["SEED"]
  require "decidim/faker/localized"

  organization = Decidim::Organization.create!(
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
    homepage_image: File.new(File.join(File.dirname(__FILE__), "seeds", "homepage_image.jpg")),
    default_locale: I18n.default_locale,
    available_locales: Decidim.available_locales
  )

  3.times.each do |index|
    Decidim::Scope.create!(
      name: Faker::Address.unique.state,
      organization: organization
    )
  end

  Decidim::User.create!(
    name: Faker::Name.name,
    email: "admin@decidim.org",
    password: "decidim123456",
    password_confirmation: "decidim123456",
    organization: organization,
    confirmed_at: Time.current,
    locale: I18n.default_locale,
    roles: ["admin"],
    tos_agreement: true,
    comments_notifications: true,
    replies_notifications: true
  )

  Decidim::User.create!(
    name: Faker::Name.name,
    email: "user@decidim.org",
    password: "decidim123456",
    password_confirmation: "decidim123456",
    confirmed_at: Time.current,
    locale: I18n.default_locale,
    organization: organization,
    tos_agreement: true,
    comments_notifications: true,
    replies_notifications: true
  )

  3.times do
    Decidim::User.all.each do |user|
      user_group = Decidim::UserGroup.create!(
        name: Faker::Company.name,
        document_number: Faker::Number.number(10),
        phone: Faker::PhoneNumber.phone_number,
        verified_at: Time.current
      )

      Decidim::UserGroupMembership.create!(
        user: user,
        user_group: user_group
      )

      user_group = Decidim::UserGroup.create!(
        name: Faker::Company.name,
        document_number: Faker::Number.number(10),
        phone: Faker::PhoneNumber.phone_number
      )

      Decidim::UserGroupMembership.create!(
        user: user,
        user_group: user_group
      )
    end
  end


  3.times do
    Decidim::ParticipatoryProcess.create!(
      title: Decidim::Faker::Localized.sentence(5),
      slug: Faker::Internet.unique.slug(nil, "-"),
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
      organization: organization,
      scope: Decidim::Faker::Localized.word,
      developer_group: Decidim::Faker::Localized.sentence(1),
      local_area: Decidim::Faker::Localized.sentence(2),
      target: Decidim::Faker::Localized.sentence(3),
      participatory_scope: Decidim::Faker::Localized.sentence(1),
      participatory_structure: Decidim::Faker::Localized.sentence(2),
      end_date: 2.month.from_now.at_midnight
    )
  end

  Decidim::ParticipatoryProcess.find_each do |process|
    Decidim::ParticipatoryProcessStep.create!(
      title: Decidim::Faker::Localized.sentence(1, false, 2),
      short_description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.sentence(3)
      end,
      description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(3)
      end,
      active: true,
      start_date: 1.month.ago.at_midnight,
      end_date: 2.months.from_now.at_midnight,
      participatory_process: process
    )
  end

  Decidim::ParticipatoryProcess.find_each do |process|
    Decidim::Attachment.create!(
      title: Decidim::Faker::Localized.sentence(2),
      description: Decidim::Faker::Localized.sentence(5),
      file: File.new(File.join(File.dirname(__FILE__), "seeds", "city.jpeg")),
      attached_to: process
    )
    Decidim::Attachment.create!(
      title: Decidim::Faker::Localized.sentence(2),
      description: Decidim::Faker::Localized.sentence(5),
      file: File.new(File.join(File.dirname(__FILE__), "seeds", "Exampledocument.pdf")),
      attached_to: process
    )
    2.times do
      Decidim::Category.create!(
        name: Decidim::Faker::Localized.sentence(5),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        participatory_process: process
      )
    end
  end
end

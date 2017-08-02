# frozen_string_literal: true

if !Rails.env.production? || ENV["SEED"]
  require "decidim/faker/localized"

  seeds_root = File.join(__dir__, "seeds")

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
    homepage_image: File.new(File.join(seeds_root, "homepage_image.jpg")),
    default_locale: Decidim.default_locale,
    available_locales: Decidim.available_locales,
    reference_prefix: Faker::Name.suffix
  )

  province = Decidim::ScopeType.create!(
    name: Decidim::Faker::Localized.literal("province"),
    plural: Decidim::Faker::Localized.literal("provinces"),
    organization: organization
  )

  municipality = Decidim::ScopeType.create!(
    name: Decidim::Faker::Localized.literal("municipality"),
    plural: Decidim::Faker::Localized.literal("municipalities"),
    organization: organization
  )

  3.times.each do
    parent = Decidim::Scope.create!(
      name: Decidim::Faker::Localized.literal(Faker::Address.unique.state),
      code: Faker::Address.unique.country_code,
      scope_type: province,
      organization: organization
    )

    5.times.each do
      Decidim::Scope.create!(
        name: Decidim::Faker::Localized.literal(Faker::Address.unique.city),
        code: parent.code + "-" + Faker::Address.unique.state_abbr,
        scope_type: municipality,
        organization: organization,
        parent: parent
      )
    end
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

  process_groups = []
  3.times do
    process_groups << Decidim::ParticipatoryProcessGroup.create!(
      name: Decidim::Faker::Localized.sentence(3),
      description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(3)
      end,
      hero_image: File.new(File.join(seeds_root, "city.jpeg")),
      organization: organization
    )
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
      hero_image: File.new(File.join(seeds_root, "city.jpeg")),
      banner_image: File.new(File.join(seeds_root, "city2.jpeg")),
      promoted: true, published_at: 2.weeks.ago,
      organization: organization,
      meta_scope: Decidim::Faker::Localized.word,
      developer_group: Decidim::Faker::Localized.sentence(1),
      local_area: Decidim::Faker::Localized.sentence(2),
      target: Decidim::Faker::Localized.sentence(3),
      participatory_scope: Decidim::Faker::Localized.sentence(1),
      participatory_structure: Decidim::Faker::Localized.sentence(2),
      end_date: 2.month.from_now.at_midnight,
      participatory_process_group: process_groups.sample,
      scope: Faker::Boolean.boolean(0.5) ? nil : Decidim::Scope.reorder("RANDOM()").first
    )
  end

  Decidim::ParticipatoryProcess.find_each do |process|
    Decidim::ParticipatoryProcessStep.find_or_initialize_by(
      participatory_process: process,
      active: true
    ).update!(
      title: Decidim::Faker::Localized.sentence(1, false, 2),
      description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(3)
      end,
      start_date: 1.month.ago.at_midnight,
      end_date: 2.months.from_now.at_midnight
    )

    # Create users with specific roles
    Decidim::ParticipatoryProcessUserRole::ROLES.each do |role|
      email = "participatory_process_#{process.id}_#{role}@example.org"

      user = Decidim::User.find_or_initialize_by(email: email)
      user.update!(
        name: Faker::Name.name,
        password: "decidim123456",
        password_confirmation: "decidim123456",
        organization: organization,
        confirmed_at: Time.current,
        locale: I18n.default_locale,
        tos_agreement: true,
        comments_notifications: true,
        replies_notifications: true
      )

      Decidim::ParticipatoryProcessUserRole.find_or_create_by!(
        user: user,
        participatory_process: process,
        role: role
      )
    end

    Decidim::Attachment.create!(
      title: Decidim::Faker::Localized.sentence(2),
      description: Decidim::Faker::Localized.sentence(5),
      file: File.new(File.join(seeds_root, "city.jpeg")),
      attached_to: process
    )

    Decidim::Attachment.create!(
      title: Decidim::Faker::Localized.sentence(2),
      description: Decidim::Faker::Localized.sentence(5),
      file: File.new(File.join(seeds_root, "Exampledocument.pdf")),
      attached_to: process
    )

    2.times do
      Decidim::Category.create!(
        name: Decidim::Faker::Localized.sentence(5),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        participatory_space: process
      )
    end
  end
end

# frozen_string_literal: true

if !Rails.env.production? || ENV["SEED"]
  print "Creating seeds for decidim-core...\n" unless Rails.env.test?

  require "decidim/faker/localized"
  require "decidim/faker/internet"

  seeds_root = File.join(__dir__, "seeds")

  # Since we usually migrate and seed in the same process, make sure
  # that we don't have invalid or cached information after a migration.
  decidim_tables = ActiveRecord::Base.connection.tables.select do |table|
    table.starts_with?("decidim_")
  end
  decidim_tables.map do |table|
    table.tr("_", "/").classify.safe_constantize
  end.compact.each(&:reset_column_information)

  smtp_label = Faker::Twitter.unique.screen_name
  smtp_email = Faker::Internet.email

  organization = Decidim::Organization.first || Decidim::Organization.create!(
    name: Faker::Company.name,
    twitter_handler: Faker::Hipster.word,
    facebook_handler: Faker::Hipster.word,
    instagram_handler: Faker::Hipster.word,
    youtube_handler: Faker::Hipster.word,
    github_handler: Faker::Hipster.word,
    smtp_settings: {
      from: "#{smtp_label} <#{smtp_email}>",
      from_email: smtp_email,
      from_label: smtp_label,
      user_name: Faker::Twitter.unique.screen_name,
      encrypted_password: Decidim::AttributeEncryptor.encrypt(Faker::Internet.password(min_length: 8)),
      address: ENV["DECIDIM_HOST"] || "localhost",
      port: ENV["DECIDIM_SMTP_PORT"] || "25"
    },
    host: ENV["DECIDIM_HOST"] || "localhost",
    description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
      Decidim::Faker::Localized.sentence(word_count: 15)
    end,
    default_locale: Decidim.default_locale,
    available_locales: Decidim.available_locales,
    reference_prefix: Faker::Name.suffix,
    available_authorizations: Decidim.authorization_workflows.map(&:name),
    users_registration_mode: :enabled,
    tos_version: Time.current,
    badges_enabled: true,
    user_groups_enabled: true,
    send_welcome_notification: true,
    file_upload_settings: Decidim::OrganizationSettings.default(:upload)
  )

  if organization.top_scopes.none?
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

    3.times do
      parent = Decidim::Scope.create!(
        name: Decidim::Faker::Localized.literal(Faker::Address.unique.state),
        code: Faker::Address.unique.country_code,
        scope_type: province,
        organization: organization
      )

      5.times do
        Decidim::Scope.create!(
          name: Decidim::Faker::Localized.literal(Faker::Address.unique.city),
          code: "#{parent.code}-#{Faker::Address.unique.state_abbr}",
          scope_type: municipality,
          organization: organization,
          parent: parent
        )
      end
    end
  end

  territorial = Decidim::AreaType.create!(
    name: Decidim::Faker::Localized.literal("territorial"),
    plural: Decidim::Faker::Localized.literal("territorials"),
    organization: organization
  )

  sectorial = Decidim::AreaType.create!(
    name: Decidim::Faker::Localized.literal("sectorials"),
    plural: Decidim::Faker::Localized.literal("sectorials"),
    organization: organization
  )

  3.times do
    Decidim::Area.create!(
      name: Decidim::Faker::Localized.word,
      area_type: territorial,
      organization: organization
    )
  end

  5.times do
    Decidim::Area.create!(
      name: Decidim::Faker::Localized.word,
      area_type: sectorial,
      organization: organization
    )
  end

  admin = Decidim::User.find_or_initialize_by(email: "admin@example.org")

  admin.update!(
    name: Faker::Name.name,
    nickname: Faker::Twitter.unique.screen_name,
    password: "decidim123456",
    password_confirmation: "decidim123456",
    organization: organization,
    confirmed_at: Time.current,
    locale: I18n.default_locale,
    admin: true,
    tos_agreement: true,
    personal_url: Faker::Internet.url,
    about: Faker::Lorem.paragraph(sentence_count: 2),
    accepted_tos_version: organization.tos_version,
    admin_terms_accepted_at: Time.current
  )

  regular_user = Decidim::User.find_or_initialize_by(email: "user@example.org")

  regular_user.update!(
    name: Faker::Name.name,
    nickname: Faker::Twitter.unique.screen_name,
    password: "decidim123456",
    password_confirmation: "decidim123456",
    confirmed_at: Time.current,
    locale: I18n.default_locale,
    organization: organization,
    tos_agreement: true,
    personal_url: Faker::Internet.url,
    about: Faker::Lorem.paragraph(sentence_count: 2),
    accepted_tos_version: organization.tos_version
  )

  locked_user = Decidim::User.find_or_initialize_by(email: "locked_user@example.org")

  locked_user.update!(
    name: Faker::Name.name,
    nickname: Faker::Twitter.unique.screen_name,
    password: "decidim123456",
    password_confirmation: "decidim123456",
    confirmed_at: Time.current,
    locale: I18n.default_locale,
    organization: organization,
    tos_agreement: true,
    personal_url: Faker::Internet.url,
    about: Faker::Lorem.paragraph(sentence_count: 2),
    accepted_tos_version: organization.tos_version
  )

  locked_user.lock_access!

  Decidim::Messaging::Conversation.start!(
    originator: admin,
    interlocutors: [regular_user],
    body: "Hey! I'm glad you like Decidim"
  )

  Decidim::User.find_each do |user|
    [nil, Time.current].each do |verified_at|
      user_group = Decidim::UserGroup.create!(
        name: Faker::Company.unique.name,
        nickname: Faker::Twitter.unique.screen_name,
        email: Faker::Internet.email,
        confirmed_at: Time.current,
        extended_data: {
          document_number: Faker::Number.number(digits: 10).to_s,
          phone: Faker::PhoneNumber.phone_number,
          verified_at: verified_at
        },
        decidim_organization_id: user.organization.id
      )

      Decidim::UserGroupMembership.create!(
        user: user,
        role: "creator",
        user_group: user_group
      )
    end
  end

  Decidim::OAuthApplication.create!(
    organization: organization,
    name: "Test OAuth application",
    organization_name: "Example organization",
    organization_url: "http://www.example.org",
    organization_logo: File.new(File.join(seeds_root, "homepage_image.jpg")), # Keep after organization
    redirect_uri: "https://www.example.org/oauth/decidim",
    scopes: "public"
  )

  Decidim::System::CreateDefaultContentBlocks.call(organization)

  hero_content_block = Decidim::ContentBlock.find_by(organization: organization, manifest_name: :hero, scope_name: :homepage)
  hero_content_block.images_container.background_image = File.new(File.join(seeds_root, "homepage_image.jpg"))
  settings = {}
  welcome_text = Decidim::Faker::Localized.sentence(word_count: 5)
  settings = welcome_text.inject(settings) { |acc, (k, v)| acc.update("welcome_text_#{k}" => v) }
  hero_content_block.settings = settings
  hero_content_block.save!
end

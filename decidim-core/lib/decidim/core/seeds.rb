# frozen_string_literal: true

require "faker"
require "decidim/seeds"
require "decidim/faker/localized"
require "decidim/faker/internet"

module Decidim
  module Core
    class Seeds < Decidim::Seeds
      def call
        print "Creating seeds for decidim-core...\n" unless Rails.env.test? # rubocop:disable Rails/Output

        reset_column_information

        organization = create_organization!

        if organization.top_scopes.none?
          province = create_scope_type!(name: "province", plural: "provinces")
          municipality = create_scope_type!(name: "municipality", plural: "municipalities")

          3.times do
            parent = create_scope!(scope_type: province, parent: nil)

            5.times do
              create_scope!(scope_type: municipality, parent:)
            end
          end
        end

        territorial = create_area_type!(name: "territorial", plural: "territorials")
        sectorial = create_area_type!(name: "sectorials", plural: "sectorials")

        3.times do
          create_area!(area_type: territorial)
        end

        5.times do
          create_area!(area_type: sectorial)
        end

        admin = find_or_initialize_user_by(email: "admin@example.org")
        admin.update!(
          admin: true,
          admin_terms_accepted_at: Time.current
        )

        ["user@example.org", "user2@example.org"].each do |email|
          find_or_initialize_user_by(email:)
        end

        regular_user = Decidim::User.find_or_initialize_by(email: "user@example.org")

        locked_user = find_or_initialize_user_by(email: "locked_user@example.org")

        locked_user.lock_access!

        Decidim::Messaging::Conversation.start!(
          originator: admin,
          interlocutors: [regular_user],
          body: "Hey! I am glad you like Decidim"
        )

        Decidim::User.find_each do |user|
          [nil, Time.current].each do |verified_at|
            create_user_group!(user:, verified_at:)
          end
        end

        oauth_application = Decidim::OAuthApplication.create!(
          organization:,
          name: "Test OAuth application",
          organization_name: "Example organization",
          organization_url: "http://www.example.org",
          redirect_uri: "https://www.example.org/oauth/decidim",
          scopes: "public"
        )

        oauth_application.organization_logo.attach(io: File.open(File.join(seeds_root, "homepage_image.jpg")), filename: "organization_logo.jpg", content_type: "image/jpeg")

        Decidim::System::CreateDefaultContentBlocks.call(organization)

        hero_content_block = Decidim::ContentBlock.find_by(organization:, manifest_name: :hero, scope_name: :homepage)
        hero_content_block.images_container.background_image = create_blob!(seeds_file: "homepage_image.jpg", filename: "homepage_image.jpg", content_type: "image/jpeg")
        settings = {}
        welcome_text = Decidim::Faker::Localized.sentence(word_count: 5)
        settings = welcome_text.inject(settings) { |acc, (k, v)| acc.update("welcome_text_#{k}" => v) }
        hero_content_block.settings = settings
        hero_content_block.save!
      end

      def reset_column_information
        # Since we usually migrate and seed in the same process, make sure
        # that we do not have invalid or cached information after a migration.
        decidim_tables = ActiveRecord::Base.connection.tables.select do |table|
          table.starts_with?("decidim_")
        end
        decidim_tables.map do |table|
          table.tr("_", "/").classify.safe_constantize
        end.compact.each(&:reset_column_information)
      end

      def create_organization!
        smtp_label = ENV.fetch("SMTP_FROM_LABEL", ::Faker::Twitter.unique.screen_name)
        smtp_email = ENV.fetch("SMTP_FROM_EMAIL", ::Faker::Internet.email)

        primary_color, secondary_color, tertiary_color = [
          ["#e02d2d", "#155abf", "#ebc34b"],
          ["#4caf50", "#a0309e", "#a8753e"],
          ["#e91e63", "#1ee9a5", "#e9b61e"],
          ["#009688", "#d12c26", "#b4a110"],
          ["#ff9800", "#00bcd4", "#ea0094"]
        ].sample

        colors = {
          alert: "#e7131a",
          primary: primary_color,
          secondary: secondary_color,
          tertiary: tertiary_color,
          success: "#28a745",
          warning: "#ffb703"
        }

        Decidim::Organization.first || Decidim::Organization.create!(
          name: ::Faker::Company.name,
          twitter_handler: ::Faker::Hipster.word,
          facebook_handler: ::Faker::Hipster.word,
          instagram_handler: ::Faker::Hipster.word,
          youtube_handler: ::Faker::Hipster.word,
          github_handler: ::Faker::Hipster.word,
          smtp_settings: {
            from: "#{smtp_label} <#{smtp_email}>",
            from_email: smtp_email,
            from_label: smtp_label,
            user_name: ENV.fetch("SMTP_USERNAME", ::Faker::Twitter.unique.screen_name),
            encrypted_password: Decidim::AttributeEncryptor.encrypt(ENV.fetch("SMTP_PASSWORD", ::Faker::Internet.password(min_length: 8))),
            address: ENV.fetch("SMTP_ADDRESS", nil) || ENV.fetch("DECIDIM_HOST", "localhost"),
            port: ENV.fetch("SMTP_PORT", nil) || ENV.fetch("DECIDIM_SMTP_PORT", "25")
          },
          host: ENV.fetch("DECIDIM_HOST", "localhost"),
          secondary_hosts: ENV.fetch("DECIDIM_HOST", "localhost") == "localhost" ? ["0.0.0.0", "127.0.0.1"] : nil,
          external_domain_allowlist: ["decidim.org", "github.com"],
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.sentence(word_count: 15)
          end,
          default_locale: Decidim.default_locale,
          available_locales: Decidim.available_locales,
          reference_prefix: ::Faker::Name.suffix,
          available_authorizations: Decidim.authorization_workflows.map(&:name),
          users_registration_mode: :enabled,
          tos_version: Time.current,
          badges_enabled: true,
          user_groups_enabled: true,
          send_welcome_notification: true,
          file_upload_settings: Decidim::OrganizationSettings.default(:upload),
          colors:
        )
      end

      def create_scope_type!(name:, plural:)
        Decidim::ScopeType.create!(
          name: Decidim::Faker::Localized.literal(name),
          plural: Decidim::Faker::Localized.literal(plural),
          organization:
        )
      end

      def create_scope!(scope_type:, parent:)
        n = rand(3)
        code = parent.nil? ? "#{::Faker::Address.country_code}_#{n}" : "#{parent.code}-#{::Faker::Address.unique.state_abbr}"

        Decidim::Scope.create!(
          name: Decidim::Faker::Localized.literal(::Faker::Address.unique.state),
          code:,
          scope_type:,
          organization:,
          parent:
        )
      end

      def create_area_type!(name:, plural:)
        Decidim::AreaType.create!(
          name: Decidim::Faker::Localized.literal(name),
          plural: Decidim::Faker::Localized.literal(plural),
          organization:
        )
      end

      def create_area!(area_type:)
        Decidim::Area.create!(
          name: Decidim::Faker::Localized.word,
          area_type:,
          organization:
        )
      end

      def create_user_group!(user:, verified_at:)
        user_group = Decidim::UserGroup.create!(
          name: ::Faker::Company.unique.name,
          nickname: ::Faker::Twitter.unique.screen_name,
          email: ::Faker::Internet.email,
          confirmed_at: Time.current,
          extended_data: {
            document_number: ::Faker::Number.number(digits: 10).to_s,
            phone: ::Faker::PhoneNumber.phone_number,
            verified_at:
          },
          decidim_organization_id: user.organization.id
        )

        Decidim::UserGroupMembership.create!(
          user:,
          role: "creator",
          user_group:
        )
      end
    end
  end
end

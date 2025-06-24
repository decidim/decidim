# frozen_string_literal: true

require "decidim/components/namer"

module Decidim
  module Elections
    class Seeds < Decidim::Seeds
      attr_reader :participatory_space

      def initialize(participatory_space:)
        @participatory_space = participatory_space
      end

      def call
        component = create_component!

        number_of_records.times do
          election = create_election!(component:)
          create_questions_for!(election) if ::Faker::Boolean.boolean(true_ratio: 0.3)
          create_voters_for!(election) if election.census_manifest == "token_csv"
        end
      end

      def create_component!
        params = {
          name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :elections).i18n_name,
          published_at: nil,
          manifest_name: :elections,
          participatory_space:
        }

        Decidim.traceability.perform_action!(
          "publish",
          Decidim::Component,
          admin_user,
          visibility: "all"
        ) do
          Decidim::Component.create!(params)
        end
      end

      def create_election!(component:)
        census_manifest = %w(internal_users token_csv).sample
        handlers = ["", "id_documents", "postal_letter", "csv_census", "dummy_authorization_handler", "ephemeral_dummy_authorization_handler", "another_dummy_authorization_handler", "sms"]
        census_settings = census_manifest == "internal_users" ? { "verification_handlers" => handlers.sample(rand(1..2)) } : {}

        params = {
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          component:,
          start_at: Time.current,
          end_at: 1.day.from_now,
          census_manifest:,
          census_settings:
        }

        Decidim.traceability.perform_action!(
          "publish",
          Decidim::Elections::Election,
          admin_user,
          visibility: "all"
        ) do
          Decidim::Elections::Election.create!(params)
        end
      end

      def create_questions_for!(election)
        number_of_records.times do |position|
          question = Decidim::Elections::Question.create!(
            election:,
            position:,
            mandatory: [true, false].sample,
            question_type: %w(single_option multiple_option).sample,
            body: Decidim::Faker::Localized.sentence(word_count: 4),
            description: Decidim::Faker::Localized.paragraph
          )

          rand(2..4).times do
            Decidim::Elections::ResponseOption.create!(
              question:,
              body: Decidim::Faker::Localized.sentence(word_count: 2)
            )
          end
        end
      end

      def create_voters_for!(election)
        number_of_records.times do |i|
          Decidim::Elections::Voter.create!(
            election: election,
            data: {
              "email" => "user#{i + 1}@example.org",
              "token" => SecureRandom.hex(6).upcase
            }
          )
        end
      end

      def organization
        @organization ||= Decidim::Organization.first
      end

      def admin_user
        @admin_user ||= Decidim::User.find_by(organization:, email: "admin@example.org")
      end
    end
  end
end

# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/seeds"

module Decidim
  module Meetings
    class Seeds < Decidim::Seeds
      attr_reader :participatory_space

      def initialize(participatory_space:)
        @participatory_space = participatory_space
      end

      def call
        component = create_component!

        if participatory_space.scope
          scopes = participatory_space.scope.descendants
          global = participatory_space.scope
        else
          scopes = participatory_space.organization.scopes
          global = nil
        end

        2.times do
          start_time = ::Faker::Date.between(from: 20.weeks.ago, to: 20.weeks.from_now)
          end_time = start_time + [rand(1..4).hours, rand(1..20).days].sample
          params = {
            component:,
            scope: ::Faker::Boolean.boolean(true_ratio: 0.5) ? global : scopes.sample,
            category: participatory_space.categories.sample,
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            location: Decidim::Faker::Localized.sentence,
            location_hints: Decidim::Faker::Localized.sentence,
            start_time:,
            end_time:,
            address: "#{::Faker::Address.street_address} #{::Faker::Address.zip} #{::Faker::Address.city}",
            latitude: ::Faker::Address.latitude,
            longitude: ::Faker::Address.longitude,
            registrations_enabled: [true, false].sample,
            available_slots: (10..50).step(10).to_a.sample,
            author: participatory_space.organization,
            registration_terms: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            published_at: ::Faker::Boolean.boolean(true_ratio: 0.8) ? Time.current : nil
          }

          _hybrid_meeting = Decidim.traceability.create!(
            Decidim::Meetings::Meeting,
            admin_user,
            params.merge(
              title: Decidim::Faker::Localized.sentence(word_count: 2),
              type_of_meeting: :hybrid,
              online_meeting_url: "http://example.org"
            ),
            visibility: "all"
          )

          _online_meeting = Decidim.traceability.create!(
            Decidim::Meetings::Meeting,
            admin_user,
            params.merge(
              title: Decidim::Faker::Localized.sentence(word_count: 2),
              type_of_meeting: :online,
              online_meeting_url: "http://example.org"
            ),
            visibility: "all"
          )

          meeting = Decidim.traceability.create!(
            Decidim::Meetings::Meeting,
            admin_user,
            params,
            visibility: "all"
          )

          2.times do
            Decidim::Meetings::Service.create!(
              meeting:,
              title: Decidim::Faker::Localized.sentence(word_count: 2),
              description: Decidim::Faker::Localized.sentence(word_count: 5)
            )
          end

          Decidim::Forms::Questionnaire.create!(
            title: Decidim::Faker::Localized.paragraph,
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            tos: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 2)
            end,
            questionnaire_for: meeting
          )

          2.times do |n|
            email = "meeting-registered-user-#{meeting.id}-#{n}@example.org"
            name = "#{::Faker::Name.name} #{meeting.id} #{n}"
            user = Decidim::User.find_or_initialize_by(email:)

            user.update!(
              password: "decidim123456789",
              name:,
              nickname: ::Faker::Twitter.unique.screen_name,
              organization: component.organization,
              tos_agreement: "1",
              confirmed_at: Time.current,
              personal_url: ::Faker::Internet.url,
              about: ::Faker::Lorem.paragraph(sentence_count: 2)
            )

            Decidim::Meetings::Registration.create!(
              meeting:,
              user:
            )
          end

          attachment_collection = create_attachment_collection(collection_for: meeting)
          create_attachment(attached_to: meeting, filename: "Exampledocument.pdf", attachment_collection:)
          create_attachment(attached_to: meeting, filename: "city.jpeg")
          create_attachment(attached_to: meeting, filename: "Exampledocument.pdf")
        end

        authors = [
          Decidim::UserGroup.where(decidim_organization_id: participatory_space.decidim_organization_id).verified.sample,
          Decidim::User.where(decidim_organization_id: participatory_space.decidim_organization_id).all.sample
        ]

        authors.each do |author|
          user_group = nil

          if author.is_a?(Decidim::UserGroup)
            user_group = author
            author = user_group.users.sample
          end

          start_time = ::Faker::Date.between(from: 20.weeks.ago, to: 20.weeks.from_now)
          params = {
            component:,
            scope: ::Faker::Boolean.boolean(true_ratio: 0.5) ? global : scopes.sample,
            category: participatory_space.categories.sample,
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            location: Decidim::Faker::Localized.sentence,
            location_hints: Decidim::Faker::Localized.sentence,
            start_time:,
            end_time: start_time + rand(1..4).hours,
            address: "#{::Faker::Address.street_address} #{::Faker::Address.zip} #{::Faker::Address.city}",
            latitude: ::Faker::Address.latitude,
            longitude: ::Faker::Address.longitude,
            registrations_enabled: [true, false].sample,
            available_slots: (10..50).step(10).to_a.sample,
            author:,
            user_group:
          }

          Decidim.traceability.create!(
            Decidim::Meetings::Meeting,
            authors[0],
            params,
            visibility: "all"
          )
        end
      end

      def create_component!
        params = {
          name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :meetings).i18n_name,
          published_at: Time.current,
          manifest_name: :meetings,
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
    end
  end
end

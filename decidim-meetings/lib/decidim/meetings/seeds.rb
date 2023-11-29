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

        2.times do
          create_meeting!(component:, type: :online)
          create_meeting!(component:, type: :hybrid)
          meeting = create_meeting!(component:, type: :in_person)

          2.times do
            create_service!(meeting:)
          end

          create_questionnaire_for!(meeting:)

          2.times do |_n|
            create_meeting_registration!(meeting:)
          end

          create_attachments!(attached_to: meeting)
        end

        create_meeting!(component:, type: [:in_person, :online, :hybrid].sample, author_type: :user)
        create_meeting!(component:, type: [:in_person, :online, :hybrid].sample, author_type: :user_group)
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

      def meeting_params(component:, type:, author_type:)
        start_time = ::Faker::Date.between(from: 20.weeks.ago, to: 20.weeks.from_now)
        end_time = start_time + [rand(1..4).hours, rand(1..20).days].sample

        params = {
          component:,
          scope: random_scope(participatory_space:),
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

        params = case type
                 when :hybrid
                   params.merge(
                     title: Decidim::Faker::Localized.sentence(word_count: 2),
                     type_of_meeting: :hybrid,
                     online_meeting_url: "https://www.youtube.com/watch?v=f6JMgJAQ2tc"
                   )
                 when :online
                   params.merge(
                     location: nil,
                     location_hints: nil,
                     latitude: nil,
                     longitude: nil,
                     title: Decidim::Faker::Localized.sentence(word_count: 2),
                     type_of_meeting: :online,
                     online_meeting_url: "https://www.youtube.com/watch?v=f6JMgJAQ2tc"
                   )
                 else
                   params # :in_person
                 end

        case author_type
        when :user
          params.merge(
            author: Decidim::User.where(decidim_organization_id: participatory_space.decidim_organization_id).all.sample
          )
        when :user_group
          user_group = Decidim::UserGroup.where(decidim_organization_id: participatory_space.decidim_organization_id).verified.sample
          author = user_group.users.sample

          params.merge(
            author:,
            user_group:
          )
        else
          params # oficial
        end
      end

      # Create a meeting
      #
      # @param component [Decidim::Component] The component where this class will be created
      # @param type [:in_person, :hybrid, :online] The meeting type
      # @param author_type [:official, :user, :user_group] Which type the author of the meeting will be
      #
      # @return [Decidim::Meeting]
      def create_meeting!(component:, type: :in_person, author_type: :official)
        params = meeting_params(component:, type:, author_type:)

        Decidim.traceability.create!(
          Decidim::Meetings::Meeting,
          admin_user,
          params,
          visibility: "all"
        )
      end

      def create_service!(meeting:)
        Decidim::Meetings::Service.create!(
          meeting:,
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          description: Decidim::Faker::Localized.sentence(word_count: 5)
        )
      end

      def create_questionnaire_for!(meeting:)
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
      end

      def create_meeting_registration!(meeting:)
        r = SecureRandom.hex(4)
        email = "meeting-registered-user-#{meeting.id}-#{r}@example.org"
        name = "#{::Faker::Name.name} #{meeting.id} #{r}"
        user = Decidim::User.find_or_initialize_by(email:)

        user.update!(
          password: "decidim123456789",
          name:,
          nickname: ::Faker::Twitter.unique.screen_name,
          organization:,
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
    end
  end
end

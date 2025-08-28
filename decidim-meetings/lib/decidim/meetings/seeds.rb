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

        number_of_records.times do
          create_meeting!(component:, type: :online)
          create_meeting!(component:, type: :online_live_event)
          create_meeting!(component:, type: :hybrid)
          meeting = create_meeting!(component:, type: :in_person)

          number_of_records.times do
            create_service!(meeting:)
          end

          create_questionnaire_for!(meeting:)

          number_of_records.times do |_n|
            create_meeting_registration!(meeting:)
          end

          create_attachments!(attached_to: meeting)
        end

        create_meeting!(component:, type: [:in_person, :online, :hybrid].sample, author_type: :user)
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
        registration_type = Decidim::Meetings::Meeting::REGISTRATION_TYPES.keys.sample

        params = {
          component:,
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          location: Decidim::Faker::Localized.sentence(word_count: rand(2..20)),
          location_hints: Decidim::Faker::Localized.sentence(word_count: rand(2..20)),
          start_time:,
          end_time:,
          address: "#{::Faker::Address.street_address} #{::Faker::Address.zip} #{::Faker::Address.city}",
          latitude: ::Faker::Address.latitude,
          longitude: ::Faker::Address.longitude,
          registrations_enabled: [true, false].sample,
          available_slots: (10..50).step(10).to_a.sample,
          author: participatory_space.organization,
          registration_type:,
          registration_terms: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          published_at: ::Faker::Boolean.boolean(true_ratio: 0.8) ? Time.current : nil
        }

        params = case type
                 when :hybrid
                   params.merge(
                     type_of_meeting: :hybrid,
                     online_meeting_url: "https://www.youtube.com/watch?v=f6JMgJAQ2tc",
                     iframe_access_level: :all,
                     iframe_embed_type: [:embed_in_meeting_page, :open_in_live_event_page, :open_in_new_tab].sample
                   )
                 when :online
                   params.merge(
                     location: nil,
                     location_hints: nil,
                     latitude: nil,
                     longitude: nil,
                     type_of_meeting: :online,
                     online_meeting_url: "https://www.youtube.com/watch?v=f6JMgJAQ2tc",
                     iframe_access_level: :all,
                     iframe_embed_type: [:embed_in_meeting_page, :open_in_live_event_page, :open_in_new_tab].sample
                   )
                 when :online_live_event
                   params.merge(
                     location: nil,
                     location_hints: nil,
                     latitude: nil,
                     longitude: nil,
                     type_of_meeting: :online,
                     online_meeting_url: "https://www.youtube.com/watch?v=f6JMgJAQ2tc",
                     iframe_access_level: :all,
                     iframe_embed_type: :open_in_live_event_page
                   )
                 else
                   params # :in_person
                 end

        params = case registration_type
                 when :on_different_platform
                   params.merge(registration_url: Faker::Internet.url)
                 when :on_this_platform
                   params.merge(registrations_enabled: true)
                 else
                   params # registration_disabled
                 end

        case author_type
        when :user
          params.merge(
            author: Decidim::User.where(decidim_organization_id: participatory_space.decidim_organization_id).all.sample
          )
        else
          params # official
        end
      end

      # Create a meeting
      #
      # @param component [Decidim::Component] The component where this class will be created
      # @param type [:in_person, :hybrid, :online, :online_live_event] The meeting type
      # @param author_type [:official, :user] Which type the author of the meeting will be
      #
      # @return [Decidim::Meeting]
      def create_meeting!(component:, type: :in_person, author_type: :official)
        params = meeting_params(component:, type:, author_type:)

        resource = Decidim.traceability.create!(
          Decidim::Meetings::Meeting,
          admin_user,
          params,
          visibility: "all"
        )

        Decidim::EventsManager.publish(
          event: "decidim.events.meetings.meeting_created",
          event_class: Decidim::Meetings::CreateMeetingEvent,
          resource:,
          followers: resource.participatory_space.followers
        )

        Decidim.traceability.perform_action!(:publish, resource, admin_user, visibility: "all") do
          resource.publish!
        end

        Decidim::Comments::Seed.comments_for(resource)

        resource
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
        user = find_or_initialize_user_by(email:)

        Decidim::Meetings::Registration.create!(
          meeting:,
          user:
        )
      end
    end
  end
end

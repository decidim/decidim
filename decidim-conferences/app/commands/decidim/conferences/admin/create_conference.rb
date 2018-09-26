# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new
      # conference in the system.
      class CreateConference < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          if conference.persisted?
            add_admins_as_followers(conference)
            broadcast(:ok, conference)
            send_notification
          else
            form.errors.add(:hero_image, conference.errors[:hero_image]) if conference.errors.include? :hero_image
            form.errors.add(:banner_image, conference.errors[:banner_image]) if conference.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def conference
          @conference ||= Decidim.traceability.create(
            Conference,
            form.current_user,
            organization: form.current_organization,
            title: form.title,
            slogan: form.slogan,
            slug: form.slug,
            hashtag: form.hashtag,
            description: form.description,
            short_description: form.short_description,
            objectives: form.objectives,
            location: form.location,
            scopes_enabled: form.scopes_enabled,
            scope: form.scope,
            start_date: form.start_date,
            end_date: form.end_date,
            hero_image: form.hero_image,
            banner_image: form.banner_image,
            promoted: form.promoted,
            show_statistics: form.show_statistics,
            registrations_enabled: form.registrations_enabled,
            available_slots: form.available_slots || 0,
            registration_terms: form.registration_terms
          )
        end

        def add_admins_as_followers(conference)
          conference.organization.admins.each do |admin|
            form = Decidim::FollowForm
                   .from_params(followable_gid: conference.to_signed_global_id.to_s)
                   .with_context(
                     current_organization: conference.organization,
                     current_user: admin
                   )

            Decidim::CreateFollow.new(form, admin).call
          end
        end

        def send_notification
          Decidim::EventsManager.publish(
            event: "decidim.events.conferences.registrations_enabled",
            event_class: Decidim::Conferences::ConferenceRegistrationsEnabledEvent,
            resource: conference,
            recipient_ids: conference.followers.pluck(:id)
          )
        end
      end
    end
  end
end

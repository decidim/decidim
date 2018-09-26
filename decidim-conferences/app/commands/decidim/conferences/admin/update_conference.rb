# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new participatory
      # conference in the system.
      class UpdateConference < Rectify::Command
        # Public: Initializes the command.
        #
        # conference - the Conference to update
        # form - A form object with the params.
        def initialize(conference, form)
          @conference = conference
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
          update_conference

          if @conference.valid?
            broadcast(:ok, @conference)
          else
            form.errors.add(:hero_image, @conference.errors[:hero_image]) if @conference.errors.include? :hero_image
            form.errors.add(:banner_image, @conference.errors[:banner_image]) if @conference.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :conference

        def update_conference
          @conference.assign_attributes(attributes)
          save_conference if @conference.valid?
        end

        def save_conference
          transaction do
            update_conference_registrations
            @conference.save!
            send_notification_registrations_enabled if should_notify_followers_registrations_enabled?
            send_notification_update_conference if should_notify_followers_update_conference?
            schedule_upcoming_conference_notification if start_date_changed?
            Decidim.traceability.perform_action!(:update, @conference, form.current_user) do
              @conference
            end
          end
        end

        def update_conference_registrations
          @conference.registrations_enabled = form.registrations_enabled

          if form.registrations_enabled
            @conference.available_slots = form.available_slots
            @conference.registration_terms = form.registration_terms
          end
        end

        def attributes
          {
            title: form.title,
            slogan: form.slogan,
            slug: form.slug,
            hashtag: form.hashtag,
            description: form.description,
            short_description: form.short_description,
            objectives: form.objectives,
            location: form.location,
            start_date: form.start_date,
            end_date: form.end_date,
            hero_image: form.hero_image,
            banner_image: form.banner_image,
            promoted: form.promoted,
            scopes_enabled: form.scopes_enabled,
            scope: form.scope,
            show_statistics: form.show_statistics
          }
        end

        def send_notification_registrations_enabled
          Decidim::EventsManager.publish(
            event: "decidim.events.conferences.registrations_enabled",
            event_class: Decidim::Conferences::ConferenceRegistrationsEnabledEvent,
            resource: @conference,
            recipient_ids: @conference.followers.pluck(:id)
          )
        end

        def should_notify_followers_registrations_enabled?
          @conference.previous_changes["registrations_enabled"].present? && @conference.registrations_enabled?
        end

        def send_notification_update_conference
          Decidim::EventsManager.publish(
            event: "decidim.events.conferences.conference_updated",
            event_class: Decidim::Conferences::UpdateConferenceEvent,
            resource: @conference,
            recipient_ids: @conference.followers.pluck(:id)
          )
        end

        def should_notify_followers_update_conference?
          important_attributes.any? { |attr| @conference.previous_changes[attr].present? }
        end

        def important_attributes
          %w(start_date end_date location)
        end

        def start_date_changed?
          @conference.previous_changes["start_date"].present?
        end

        def schedule_upcoming_conference_notification
          checksum = Decidim::Conferences::UpcomingConferenceNotificationJob.generate_checksum(@conference)

          Decidim::Conferences::UpcomingConferenceNotificationJob
            .set(wait_until: (@conference.start_date - 2.days).to_s)
            .perform_later(@conference.id, checksum)
        end
      end
    end
  end
end

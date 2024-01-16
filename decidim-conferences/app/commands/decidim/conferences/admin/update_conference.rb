# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new participatory
      # conference in the system.
      class UpdateConference < Decidim::Commands::UpdateResource
        include ::Decidim::AttachmentAttributesMethods

        fetch_form_attributes :title, :slogan, :slug, :weight, :hashtag, :description, :short_description,
                              :objectives, :location, :start_date, :end_date, :promoted, :show_statistics,
                              :scopes_enabled, :scope, :registrations_enabled

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_conference
          link_participatory_processes
          link_assemblies

          if resource.valid?
            broadcast(:ok, resource)
          else
            form.errors.add(:hero_image, resource.errors[:hero_image]) if resource.errors.include? :hero_image
            form.errors.add(:banner_image, resource.errors[:banner_image]) if resource.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        private

        def update_conference
          resource.assign_attributes(attributes)
          save_conference if resource.valid?
        end

        def save_conference
          transaction do
            resource.save!
            send_notification_registrations_enabled if should_notify_followers_registrations_enabled?
            send_notification_update_conference if should_notify_followers_update_conference?
            schedule_upcoming_conference_notification if start_date_changed?
            Decidim.traceability.perform_action!(:update, resource, form.current_user) do
              resource
            end
          end
        end

        def registration_attributes
          return {} unless form.registrations_enabled

          {
            available_slots: form.available_slots,
            registration_terms: form.registration_terms
          }
        end

        def attributes = super.merge(registration_attributes).merge(attachment_attributes(:hero_image, :banner_image))

        def send_notification_registrations_enabled
          Decidim::EventsManager.publish(
            event: "decidim.events.conferences.registrations_enabled",
            event_class: Decidim::Conferences::ConferenceRegistrationsEnabledEvent,
            resource:,
            followers: resource.followers
          )
        end

        def should_notify_followers_registrations_enabled?
          resource.previous_changes["registrations_enabled"].present? &&
            resource.registrations_enabled? &&
            resource.published?
        end

        def send_notification_update_conference
          Decidim::EventsManager.publish(
            event: "decidim.events.conferences.conference_updated",
            event_class: Decidim::Conferences::UpdateConferenceEvent,
            resource:,
            followers: resource.followers
          )
        end

        def should_notify_followers_update_conference?
          important_attributes.any? { |attr| resource.previous_changes[attr].present? } &&
            resource.published?
        end

        def important_attributes
          %w(start_date end_date location)
        end

        def start_date_changed?
          resource.previous_changes["start_date"].present?
        end

        def schedule_upcoming_conference_notification
          checksum = Decidim::Conferences::UpcomingConferenceNotificationJob.generate_checksum(resource)

          Decidim::Conferences::UpcomingConferenceNotificationJob
            .set(wait_until: (resource.start_date - 2.days).to_s)
            .perform_later(resource.id, checksum)
        end

        def participatory_processes
          @participatory_processes ||= resource.participatory_space_sibling_scope(:participatory_processes).where(id: @form.participatory_processes_ids)
        end

        def link_participatory_processes
          resource.link_participatory_space_resources(participatory_processes, "included_participatory_processes")
        end

        def assemblies
          @assemblies ||= resource.participatory_space_sibling_scope(:assemblies).where(id: @form.assemblies_ids)
        end

        def link_assemblies
          resource.link_participatory_space_resources(assemblies, "included_assemblies")
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command that sets a Conference as published.
      class PublishConference < Decidim::Admin::ParticipatorySpace::Publish
        def call
          return broadcast(:invalid) if participatory_space.nil? || participatory_space.published?

          Decidim.traceability.perform_action!(:publish, participatory_space, user, **default_options) do
            participatory_space.publish!
          end

          send_notification
          broadcast(:ok, participatory_space)
        end

        private

        def send_notification
          return unless participatory_space.registrations_enabled?

          Decidim::EventsManager.publish(
            event: "decidim.events.conferences.registrations_enabled",
            event_class: Decidim::Conferences::ConferenceRegistrationsEnabledEvent,
            resource: participatory_space,
            followers: participatory_space.followers
          )
        end
      end
    end
  end
end

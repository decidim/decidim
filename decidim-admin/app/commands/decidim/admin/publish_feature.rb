# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when a feature is published from the admin panel.
    class PublishFeature < Rectify::Command
      # Public: Initializes the command.
      #
      # feature - The feature to publish.
      # current_user - the user performing the action
      def initialize(feature, current_user)
        @feature = feature
        @current_user = current_user
      end

      # Public: Publishes the Feature.
      #
      # Broadcasts :ok if published, :invalid otherwise.
      def call
        publish_feature
        publish_event

        broadcast(:ok)
      end

      private

      attr_reader :feature, :current_user

      def publish_feature
        Decidim.traceability.perform_action!(
          :publish,
          feature,
          current_user
        ) do
          feature.publish!
          feature
        end
      end

      def publish_event
        Decidim::EventsManager.publish(
          event: "decidim.events.features.feature_published",
          event_class: Decidim::FeaturePublishedEvent,
          resource: feature,
          recipient_ids: feature.participatory_space.followers.pluck(:id)
        )
      end
    end
  end
end

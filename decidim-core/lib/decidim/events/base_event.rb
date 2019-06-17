# frozen_string_literal: true

module Decidim
  module Events
    # This class serves as a base for all event classes. Event classes are intended to
    # add more logic to a `Decidim::Notification` and are used to render them in the
    # notifications dashboard and to generate other notifications (emails, for example).
    class BaseEvent
      extend ActiveModel::Translation
      include Decidim::TranslatableAttributes

      class_attribute :types
      self.types = []

      # Public: Stores all the notification types this event can create. Please, do not
      # overwrite this method, consider it final. Instead, add values to the array via
      # modules, take the `NotificationEvent` module as an example:
      #
      # Example:
      #
      #   module WebPushNotificationEvent
      #     extend ActiveSupport::Concern
      #
      #     included do
      #       type :web_push_notifications
      #     end
      #   end
      #
      #   class MyEvent < Decidim::Events::BaseEvent
      #     include WebPushNotificationEvent
      #   end
      #
      #   MyEvent.types # => [:web_push_notifications]
      def self.type(type)
        self.types += Array(type)
      end

      # Initializes the class.
      #
      # event_name - a String with the name of the event.
      # resource - the resource that received the event
      # user - the User that receives the event
      # user_role - the role the user takes for this event (either `:follower` or
      #   `:affected_user`)
      # extra - a Hash with extra information of the event.
      def initialize(resource:, event_name:, user:, user_role: nil, extra: {})
        @event_name = event_name
        @resource = resource
        @user = user
        @user_role = user_role
        @extra = extra.with_indifferent_access
      end

      # Caches the locator for the given resource, so that
      # we can find the resource URL.
      def resource_locator
        @resource_locator ||= Decidim::ResourceLocatorPresenter.new(resource)
      end

      # Caches the path for the given resource.
      def resource_path
        @resource_path ||= resource_locator.path
      end

      # Caches the URL for the given resource.
      def resource_url
        @resource_url ||= resource_locator.url
      end

      # Whether this event should be notified or not. Useful when you want the
      # event to decide based on the params.
      #
      # It returns false when the resource or any element in the chain is a
      # `Decidim::Publicable` and it isn't published or participatory_space
      # is a `Decidim::Participable` and the user can't participate.
      def notifiable?
        return false if resource.is_a?(Decidim::Publicable) && !resource.published?
        return false if participatory_space.is_a?(Decidim::Publicable) && !participatory_space&.published?
        return false if component && !component.published?

        return false if participatory_space.is_a?(Decidim::Participable) && !participatory_space.can_participate?(user)

        true
      end

      def resource_text; end

      def resource_title
        return unless resource

        if resource.respond_to?(:title)
          translated_attribute(resource.title)
        elsif resource.respond_to?(:name)
          translated_attribute(resource.name)
        end
      end

      private

      attr_reader :event_name, :resource, :user, :user_role, :extra

      def component
        return resource.component if resource.is_a?(Decidim::HasComponent)
        return resource if resource.is_a?(Decidim::Component)
      end

      def participatory_space
        return resource if resource.is_a?(Decidim::ParticipatorySpaceResourceable)

        component&.participatory_space
      end
    end
  end
end

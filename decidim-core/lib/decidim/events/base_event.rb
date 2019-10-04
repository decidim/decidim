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

      def resource_text; end

      def resource_title
        return unless resource

        if resource.is_a?(Decidim::Hashtaggable)
          translated_title = translated_attribute(resource.title)
          renderer = Decidim::ContentRenderers::HashtagRenderer.new(translated_title)
          renderer.render(links: false).html_safe
        elsif resource.respond_to?(:title)
          translated_attribute(resource.title)
        elsif resource.respond_to?(:name)
          translated_attribute(resource.name)
        end
      end

      private

      def component
        return resource if resource.is_a?(Decidim::Component)

        resource.try(:component)
      end

      def participatory_space
        return resource if resource.is_a?(Decidim::Participable)

        resource.try(:participatory_space)
      end

      attr_reader :event_name, :resource, :user, :user_role, :extra
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Events
    # This class serves as a base for all event classes. Event classes are intended to
    # add more logic to a `Decidim::Notification` and are used to render them in the
    # notifications dashboard and to generate other notifications (emails, for example).
    class BaseEvent
      extend ActiveModel::Translation
      include Decidim::SanitizeHelper

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
        @resource_path ||= if resource.respond_to?(:polymorphic_resource_path)
                             resource.polymorphic_resource_path(resource_url_params)
                           else
                             resource_locator.path(resource_url_params)
                           end
      end

      # Caches the URL for the given resource.
      def resource_url
        @resource_url ||= if resource.respond_to?(:polymorphic_resource_url)
                            resource.polymorphic_resource_url(resource_url_params)
                          else
                            resource_locator.url(resource_url_params)
                          end
      end

      def resource_text; end

      # The cell that will be used to render the action or nil if not action needs to be rendered.
      #
      # @return [nil] - if no action needs to be rendered
      # @return [String] - if String, it is the cell to be rendered. Make it return with "decidim/notification_actions/buttons" in your event implementation to render the buttons cell
      def action_cell; end

      # The data that will be passed to the action cell
      #
      # @return [nil] - If no data needs to be rendered
      # @return [Array<Hash{Symbol => String}>] - For the buttons cell, it should be an array of hashes with the following keys:
      #   - url: the URL to which the button will point
      #   - label: the label of the button (optional if i18n_label is present)
      #   - i18n_label: the i18n key of the label (optional if label is present)
      #   - icon: the icon of the button (optional)
      #   - method: the HTTP method of the request (optional)
      #   - class: the class of the button (optional)
      def action_data; end

      def organization
        resource.try(:organization)
      end

      def perform_translation?
        false
      end

      def content_in_same_language?
        false
      end

      def translation_missing?
        false
      end

      def safe_resource_text
        translated_attribute(resource_text).to_s.html_safe
      end

      def safe_resource_translated_text; end

      def resource_title
        return unless resource

        title = if resource.respond_to?(:title)
                  decidim_sanitize_translated(resource.title)
                elsif resource.respond_to?(:name)
                  decidim_sanitize_translated(resource.name)
                end

        Decidim::ContentProcessor.render_without_format(title, links: false).html_safe
      end

      def hidden_resource?
        resource.respond_to?(:hidden?) && resource.hidden?
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

      def resource_url_params
        {}
      end

      attr_reader :event_name, :resource, :user, :user_role, :extra
    end
  end
end

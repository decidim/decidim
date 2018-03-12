# frozen_string_literal: true

module Decidim
  module Events
    # Extends the BaseEvent to add common components to most events so you don't
    # need to write each time the same code.
    #
    # The only convention you need to keep in mind is that the event name will be
    # used as the i18n scope to search for the keys.
    class SimpleEvent < BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent
      include Decidim::ComponentPathHelper

      class_attribute :i18n_interpolations
      self.i18n_interpolations = []

      # Public: A method to add values to pass as interpolations to the I18n.t method.
      #
      # By default the resource_path, resource_title and resource_url are already included.
      #
      # attribute - A Symbol of the method name (and interpolation value) to add.
      #
      # Example:
      #
      #   class MyEvent < Decidim::Events::SimpleEvent
      #     i18n_attributes :participatory_space_title
      #   end
      def self.i18n_attributes(*attributes)
        self.i18n_interpolations += Array(attributes)
      end

      def email_subject
        I18n.t("email_subject", i18n_options).html_safe
      end

      def email_intro
        I18n.t("email_intro", i18n_options).html_safe
      end

      def email_outro
        I18n.t("email_outro", i18n_options).html_safe
      end

      def notification_title
        I18n.t("notification_title", i18n_options).html_safe
      end

      # Public: The String to use as scope to search for the keys
      # when using I18n.t
      #
      # By default is the same value as the event name.
      def i18n_scope
        event_name
      end

      # Public: The Hash of options to pass to the I18.t method.
      def i18n_options
        default_i18n_options.merge(event_interpolations)
      end

      # Caches the path for the given resource when it's a Decidim::Component.
      def resource_path
        return super unless resource.is_a?(Decidim::Component)
        @resource_path ||= main_component_path(resource)
      end

      # Caches the URL for the given resource when it's a Decidim::Component.
      def resource_url
        return super unless resource.is_a?(Decidim::Component)
        @resource_url ||= main_component_url(resource)
      end

      # Caches the URL for the resource's participatory space.
      def participatory_space_url
        return unless participatory_space

        @participatory_space_url ||= ResourceLocatorPresenter.new(participatory_space).url
      end

      private

      def event_interpolations
        Array(self.class.i18n_interpolations).inject({}) do |all, attribute|
          all.update(attribute => send(attribute))
        end
      end

      def default_i18n_options
        {
          resource_path: resource_path,
          resource_title: resource_title,
          resource_url: resource_url,
          participatory_space_title: participatory_space_title,
          participatory_space_url: participatory_space_url,
          scope: i18n_scope
        }
      end

      def participatory_space_title
        translated_attribute(participatory_space.try(:title))
      end
    end
  end
end

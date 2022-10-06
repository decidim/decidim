# frozen_string_literal: true

module Decidim
  # This class acts as a manifest for reminders.
  #
  # This manifest is a simple object that holds and stores reminder
  # and it's generator class.
  class ReminderManifest
    include ActiveModel::Model
    include Decidim::AttributeObject::Model

    attribute :generator_class_name, String
    attribute :form_class_name, String
    attribute :command_class_name, String

    validates :generator_class, presence: true

    attr_reader :name

    def initialize(name:)
      super()
      @name = name
      @messages = ReminderManifestMessages.new
    end

    def generator_class
      generator_class_name.constantize
    end

    def form_class
      form_class_name.constantize
    end

    def command_class
      command_class_name.constantize
    end

    def has_settings?
      settings.attributes.any?
    end

    def settings(&block)
      @settings ||= SettingsManifest.new
      yield(@settings) if block
      @settings
    end

    # Fetch the messages object or yield it for the block when a block is
    # given.
    def messages
      if block_given?
        yield @messages
      else
        @messages
      end
    end

    def message(key, context = nil, **extra, &)
      extra = context if extra.empty? && context.is_a?(Hash)

      if block_given?
        messages.set(key, &)
      else
        messages.render(key, context, **extra)
      end
    end

    # Returns a boolean indicating whether the message exists with the given key.
    def has_message?(key)
      messages.has?(key)
    end

    class ReminderManifestMessages < Decidim::ManifestMessages; end
  end
end

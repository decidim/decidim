# frozen_string_literal: true

module Decidim
  # This class acts as a manifest for reminders.
  #
  # This manifest is a simple object that holds and stores reminder
  # and it's manager class.
  class ReminderManifest
    include ActiveModel::Model
    include Virtus.model

    attribute :name, String
    attribute :manager_class_name, String
    attribute :form_class_name, String
    attribute :command_class_name, String

    validates :name, :manager_class, presence: true

    def manager_class
      manager_class_name.constantize
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
  end
end

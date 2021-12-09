# frozen_string_literal: true

module Decidim
  class ReminderManifest
    include ActiveModel::Model
    include Virtus.model

    attribute :reminder_name, String
    attribute :manager_class, String

    validates :reminder_name, :manager_class, presence: true

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

# frozen_string_literal: true

module Decidim
  class ReminderManifest
    include ActiveModel::Model
    include Virtus.model

    attribute :metric_name, String
    attribute :manager_class, String

    validates :metric_name, :manager_class, presence: true

    def has_settings?
      settings.attributes.any?
    end

    def settings(&block)
      @settings ||= SettingsManifest.new
      yield(@settings) if block
      @settings
    end

    # stat_block is a non-required parameter
    # This method make it easier to retrieve it,
    #  and gives an empty string if it's not configured
    def stat_block
      settings.attributes[:stat_block].try(:[], :default) || ""
    end
  end
end

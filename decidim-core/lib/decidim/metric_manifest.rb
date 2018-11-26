# frozen_string_literal: true

module Decidim
  # This class acts as a manifest for metrics.
  #
  # This manifest is a simple object that holds and stores currently available
  # metrics and his managers, for calculations purpose
  #
  class MetricManifest
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
  end
end

# frozen_string_literal: true

module Decidim
  # This class holds the configuration for notification settings at component level.
  #
  # This manifest is a simple object that holds and stores current attributes
  # and their specific validators
  class NotificationSettingManifest
    include ActiveModel::Model
    include Decidim::AttributeObject::Model

    attribute :name, Symbol
    attribute :settings_area, Symbol
    attribute :default_value, Boolean, default: true

    validates :default_value, inclusion: { in: [true, false] }
    validates :settings_area, inclusion: { in: [:global, :administrators] }
  end
end

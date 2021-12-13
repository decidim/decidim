# frozen_string_literal: true

module Decidim
  class ComponentNotificationSettingManifest
    include ActiveModel::Model
    include Virtus.model

    attribute :name, Symbol
    attribute :area, Symbol
    attribute :default_value, String, default: "0"

    validates :default_value, inclusion: { in: %w(0 1) }
    validates :area, inclusion: { in: [:global, :administrators] }
  end
end

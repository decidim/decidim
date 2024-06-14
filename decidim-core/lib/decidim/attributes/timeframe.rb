# frozen_string_literal: true

module Decidim
  module Attributes
    class Timeframe < ActiveModel::Type::Value
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :edit_time, :string, default: "limited"
      attribute :edit_time_value, :integer, default: 5
      attribute :edit_time_unit, :string, default: "minutes"

      validates :edit_time, inclusion: { in: %w(limited infinite) }
      validates :edit_time_value, presence: true, numericality: { only_integer: true }
      validates :edit_time_unit, inclusion: { in: %w(minutes hours days) }
    end
  end
end

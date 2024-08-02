# frozen_string_literal: true

module Decidim
  # This class can be used to parse ENV variables to a set of predefined values
  # For instance, "", nil, "false" or 0 will all translate into false using valid?
  class Env
    FALSE_VALUES = %w(0 false no).freeze

    def initialize(name, default = nil)
      @name = name
      @value = ENV.fetch(name, nil)
      @default = default
    end

    def value
      @value.presence || @default
    end

    delegate :to_json, :to_s, to: :value

    def blank?
      value.blank? || FALSE_VALUES.include?(value.to_s.downcase)
    end

    # rubocop:disable Rails/Present
    def present?
      !blank?
    end
    # rubocop:enable Rails/Present

    def to_boolean_string
      present?.to_s
    end

    def to_i
      str = blank? ? @default : value
      str.to_s.to_i
    end

    def to_f
      str = blank? ? @default : value
      str.to_s.to_f
    end

    def default_or_present_if_exists
      return @default unless ENV.has_key?(@name)

      @value.present? && FALSE_VALUES.exclude?(@value.to_s.downcase)
    end

    def to_array(separator: ",")
      str = blank? ? @default : value
      str.to_s.split(separator).map(&:strip)
    end

    alias to_a to_array
  end
end

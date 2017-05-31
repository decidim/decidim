# frozen_string_literal: true

module Decidim
  #
  # This class handles all logic regarding menu items
  #
  class MenuItem
    # Builds a new menu item
    #
    # @param label [String, Symbol] A compulsory label for the menu item
    # @param url [String, Symbol] The URL this item will link to
    # @param options [Hash] The options for the menu item
    #
    def initialize(label, url, options = {})
      @label = label
      @url = url
      @position = options[:position] || Float::INFINITY
      @if = options[:if]
      @active = options[:active]
      @icon_name = options[:icon_name]
    end

    attr_reader :label, :url, :position, :active, :icon_name

    def visible?
      return true if @if.nil? || @if

      false
    end
  end
end

# frozen_string_literal: true

module Decidim
  #
  # This class handles all logic regarding menu items
  #
  class MenuItem
    # Builds a new menu item
    #
    # @param label [String, Symbol, Proc] A compulsory label for the menu item
    # @param url [String, Symbol, Proc] The URL this item will link to
    # @param options [Hash] The options for the menu item
    #
    def initialize(label, url, options = {})
      @label = label
      @url = url
      @position = options.delete(:position) || Float::INFINITY
      @visible = options.delete(:if) || -> { true }
      @options = options
    end

    attr_reader :position, :options

    def label(context)
      in_context(@label, context)
    end

    def url(context)
      in_context(@url, context)
    end

    def visible?(context)
      in_context(@visible, context)
    end

    private

    def in_context(attribute, context)
      if attribute.is_a?(Proc)
        context.instance_exec(&attribute)
      else
        attribute
      end
    end
  end
end

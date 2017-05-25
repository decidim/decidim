# frozen_string_literal: true

module Decidim
  #
  # This class handles all logic regarding registering menus
  #
  class MenuRegistry
    class << self
      #
      # Finds a menu by name or creates it if it doesn't exist. Optionally,
      # registers a MenuItem DSL block for the menu.
      #
      # @param name [Symbol] Name of the menu
      # @param &block [Menu] Registration body of the menu. It's stored to be
      #                      evaluated at rendering time
      #
      def register(name, &block)
        menu = find(name) || create(name)

        menu.configurations << block

        menu
      end

      #
      # Finds a menu by name
      #
      # @param name [Symbol] The name of the menu
      #
      def find(name)
        all[name]
      end

      #
      # Creates an empty named menu
      #
      # @param name [Symbol] The name of the menu
      #
      def create(name)
        all[name] = new
      end

      #
      # Destroys a named menu
      #
      # @param name [Symbol] The name of the menu
      #
      def destroy(name)
        all[name] = nil
      end

      private

      def all
        @all ||= {}
      end
    end

    attr_reader :configurations

    def initialize
      @configurations = []
    end
  end
end

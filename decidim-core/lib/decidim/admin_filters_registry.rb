# frozen_string_literal: true

module Decidim
  #
  # This class handles all logic regarding registering filters
  #
  class AdminFiltersRegistry
    class << self
      #
      # Finds a filter by name or creates it if it does not exist.
      #
      # @param name [Symbol] Name of the filter
      # @param &block [Filter] Registration body of the filter. It is stored to
      #                        be evaluated at rendering time
      #
      def register(name, &block)
        filter = find(name) || create(name)

        filter.configurations << block

        filter
      end

      #
      # Finds a filter by name
      #
      # @param name [Symbol] The name of the filter
      #
      def find(name)
        all[name]
      end

      #
      # Creates an empty named filter
      #
      # @param name [Symbol] The name of the filter
      #
      def create(name)
        all[name] = new
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

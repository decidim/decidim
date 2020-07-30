# frozen_string_literal: true

module Decidim
  module Map
    # Generic map utility that will be used for providing different map
    # functionality to the application.
    #
    # @abstract
    class Utility
      attr_reader :organization, :configuration, :locale

      # Initializes the map utility.
      #
      # @param options [Hash] The options for the map utility
      # @option options [Decidim::Organization] :organization The organization
      #   where the map functionality is used
      # @option options [String] :config The configuration hash specific to the
      #   utility
      # @option options [String] :locale The locale to use for the queries
      def initialize(organization:, config:, locale: I18n.locale.to_s)
        @organization = organization
        @locale = locale
        configure!(config)
      end

      protected

      # Sets the local configurations for the utility.
      #
      # @param config [Hash] The whole configuration hash.
      #
      # @return [Hash] The configuration hash.
      def configure!(config)
        @configuration = config
      end
    end
  end
end

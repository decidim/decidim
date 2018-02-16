# frozen_string_literal: true

module Decidim
  module ContentParsers
    # Class to inject context information to content parsers
    #
    # @example How to create a context
    #   context = Decidim::ContentParsers::Context.new(
    #     current_organization: a_decidim_organization
    #   )
    class Context
      include ActiveSupport::Configurable

      # @!attribute [rw]
      #   @return [Decidim::Organization] the current request organization
      config_accessor :current_organization

      # Gets initialized with the attributes
      #
      # @param attributes [#to_hash] attributes
      #   the attributes hash to be set
      def initialize(attributes = nil)
        if attributes.is_a? (Hash)
          attributes.each { |key, val| send("#{key}=", val) }
        end
      end
    end
  end
end

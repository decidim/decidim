# frozen_string_literal: true

module Decidim
  module Admin
    module Import
      # This is an abstract class with a very naive default implementation
      # for the importers to use. It can also serve as a superclass of your
      # own implementation.
      #
      # It is used to be run against each element of an importable collection
      # in order to parse relevant fields. Every import should specify their
      # own parser or this default will be used.
      class Parser
        attr_reader :data

        # Initializes the parser with a resource.
        #
        # data - The data hash to parse.
        def initialize(data)
          @data = data.except(:id, "id")
        end

        # Retuns the resource class to be created with the provided data.
        def self.resource_klass
          raise NotImplementedError, "#{self.class.name} does not define resource class"
        end

        # Can be used to convert the data hash to the resource attributes in
        # case the data hash to be imported has different column names than the
        # resource object to be created of it.
        #
        # By default returns the data hash but can be implemented by each parser
        # implementation.
        #
        # Returns the resource attributes to be passed for the constructor.
        def resource_attributes
          @data
        end

        # Public: Returns a parsed object with the parsed data.
        #
        # Returns a target object.
        def parse
          self.class.resource_klass.new(resource_attributes)
        end
      end
    end
  end
end

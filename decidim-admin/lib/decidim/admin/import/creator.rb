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
      # own creator or this default will be used.
      class Creator
        attr_reader :data

        # Initializes the creator with a resource.
        #
        # data - The data hash to parse.
        # context - The context needed by the producer
        def initialize(data, context = nil)
          @data = data
          @context = context
        end

        # Retuns the resource class to be created with the provided data.
        def self.resource_klass
          raise NotImplementedError, "#{self.class.name} does not define resource class"
        end

        # Can be used to convert the data hash to the resource attributes in
        # case the data hash to be imported has different column names than the
        # resource object to be created of it.
        #
        # By default returns the data hash but can be implemented by each creator
        # implementation.
        #
        # Returns the resource attributes to be passed for the constructor.
        def resource_attributes
          @data
        end

        # Public: Returns a created object with the parsed data.
        #
        # Returns a target object.
        def produce
          self.class.resource_klass.new(resource_attributes)
        end

        def finish!
          resource.save!
        end

        def self.missing_headers(headers, available_locales)
          missing_headers = []
          required_static_headers.each do |required|
            missing_headers << required unless headers.include?(required)
          end

          required_dynamic_headers.each do |required|
            missing_headers << required unless has_localized_header?(required, headers, available_locales)
          end
          missing_headers
        end

        def self.has_localized_header?(required_header, headers, available_locales)
          localized_headers = localize_headers(required_header, available_locales)
          headers.each do |header|
            return true if localized_headers.include?(header)
          end
          false
        end

        def self.required_static_headers
          []
        end

        def self.required_dynamic_headers
          []
        end

        # Check if prepared resource is valid
        #
        # record - Instance of model created by creator.
        #
        # Returns true if record is valid
        def self.resource_valid?(record)
          return false if record.nil?

          record.valid?
        end

        def self.localize_headers(header, locales)
          @localize_headers ||= begin
            localize_headers = []
            locales.each do |locale|
              localize_headers << "#{header}/#{locale}".to_sym
            end
            localize_headers
          end
        end

        private

        def resource
          raise NotImplementedError, "#{self.class.name} does not define resource"
        end

        #
        # Collect field's language specified cells to one hash
        #
        # field - The field name eg. "title"
        # locales - Available locales
        #
        # Returns the hash including locale-imported_data pairs. eg. {en: "Heading", ca: "Cap", es: "Bóveda"}
        #
        def locale_hasher(field, locales)
          hash = {}
          locales.each do |locale|
            parsed = data[:"#{field}/#{locale}"]
            hash[locale] = parsed unless parsed.nil?
          end
          hash
        end
      end
    end
  end
end

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
        class << self
          # Retuns the resource class to be created with the provided data.
          def resource_klass
            raise NotImplementedError, "#{self.class.name} does not define resource class"
          end

          # Returns the verifier class to be used to ensure the data is valid
          # for the import.
          def verifier_klass
            Decidim::Admin::Import::Verifier
          end

          def required_headers
            []
          end

          def localize_headers(header, locales)
            @localize_headers ||= begin
              localize_headers = []
              locales.each do |locale|
                localize_headers << "#{header}/#{locale}".to_sym
              end
              localize_headers
            end
          end
        end

        attr_reader :data

        # Initializes the creator with a resource.
        #
        # data - The data hash to parse.
        # context - The context needed by the producer
        def initialize(data, context = nil)
          @data = data
          @context = context
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

        protected

        attr_reader :context

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

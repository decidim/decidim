# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This module adds support functionality to be able to generate a unique fingerprint
  # from a model, given some fields. Its goal is to provide a way to give an informal
  # "receipt" to a user to they can detect tampering.
  #
  module Fingerprintable
    extend ActiveSupport::Concern

    class_methods do
      attr_reader :fingerprint_options

      # Public: Configures fingerprinting for this model.
      #
      # fields - An `Array` of `symbols` specifying the fields that will be part of
      #          the fingerprint generation.
      # block  - (optional) When provided, it's given an instance of the model as a
      #          parameter so the fingerprint can be generated in runtime.
      #
      # Returns nothing.
      def fingerprint(fields: nil, &block)
        @fingerprint_options = {}

        if block_given?
          @fingerprint_options[:block] = block
        else
          raise "You must provide a set of fields to generate the fingerprint." unless fields

          @fingerprint_options[:fields] = fields
        end
      end
    end

    # Public: Returns an instance of `FingerprintCalculator` containing the fingerprint.
    #
    # Example:
    #
    #    model.fingerprint.value  # Returns the fingerprint as a String
    #    model.fingerprint.source # Returns the source String (usually a json) from which
    #                             # the fingerprint is generated.
    def fingerprint
      @fingerprint ||= FingerprintCalculator.new(fingerprint_data)
    end

    private

    def fingerprint_data
      options = self.class.fingerprint_options

      if options[:block]
        options[:block].call(self)
      elsif options[:fields]
        options[:fields].each_with_object({}) do |field, result|
          result[field] = send(field)
        end
      else
        raise "Fingerprinting needs to be set up via the `fingerprint` class method."
      end
    end
  end
end

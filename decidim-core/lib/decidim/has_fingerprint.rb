# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module HasFingerprint
    extend ActiveSupport::Concern

    class_methods do
      attr_reader :fingerprint_options

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

    def fingerprint
      @fingerprint ||= FingerprintCalculator.new(self, fingerprint_data)
    end

    private

    def fingerprint_data
      options = self.class.fingerprint_options

      if options[:block]
        fingerprint_options[:block].call(self)
      elsif options[:fields]
        options[:fields].each_with_object({}) do |field, result|
          result[field] = send(field)
        end
      end

      raise "Fingerprinting needs to be set up via the `fingerprint` class method."
    end
  end
end

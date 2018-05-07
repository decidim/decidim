# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module HasFingerprint
    extend ActiveSupport::Concern

    class_methods do
      def fingerprint(fields: nil, &block)
        @@fingerprint_block = nil

        if block_given?
          @@fingerprint_block = block
        else
          raise "You must provide a set of fields to generate the fingerprint." unless fields
          @@fingerprint_fields = fields
        end
      end
    end

    def fingerprint
      @fingerprint ||= FingerprintCalculator.new(self, fingerprint_data)
    end

    private

    def fingerprint_data
      if @@fingerprint_block
        @@fingerprint_block.call(self)
      else
        @@fingerprint_fields.each_with_object({}) do |field, result|
          result[field] = send(field)
        end
      end
    end
  end
end

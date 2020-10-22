# frozen_string_literal: true

module Decidim
  module Initiatives
    # Example of service to generate a timestamp for a document
    class DummyTimestamp
      attr_accessor :document

      # Public: Initializes the service.
      # document - The document for which the timestamp is going to be generated
      # signature_type
      def initialize(args = {})
        @document = args.fetch(:document)
      end

      # Public: Timestamp generated from data
      def timestamp
        @timestamp ||= Base64.encode64(OpenSSL::Digest.digest("SHA1", "#{@document}-#{Time.current}")).chop
      end
    end
  end
end

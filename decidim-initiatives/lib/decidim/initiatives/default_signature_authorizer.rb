# frozen_string_literal: true

module Decidim
  module Initiatives
    class DefaultSignatureAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
      #
      # Initializes the DefaultActionAuthorizer class.
      #
      # authorization - The existing authorization record to be evaluated. Can be nil.
      # options       - A hash with options related only to the current authorization process.
      #
      def initialize(authorization, options = {})
        super(authorization, options, nil, nil)
      end
    end
  end
end

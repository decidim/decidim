# frozen_string_literal: true

module Decidim
  module Admin
    # This class serializes a Authorization so can be exported to CSV
    class AuthorizationSerializer < Decidim::Exporters::Serializer
      attr_reader :authorization

      def initialize(authorization)
        @authorization = authorization
      end

      def serialize
        {
          id: authorization.id,
          name: authorization.name,
          granted_at: authorization.granted_at,
          postal_code: metadata["postal_code"],
          date_of_birth: metadata["date_of_birth"],
          gender: metadata["gender"]
        }
      end

      private

      def metadata
        authorization.metadata || {}
      end
    end
  end
end

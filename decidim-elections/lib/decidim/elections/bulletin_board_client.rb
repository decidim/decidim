# frozen_string_literal: true

module Decidim
  module Elections
    class BulletinBoardClient
      def initialize(params)
        @server = params[:server].presence
        @api_key = params[:api_key].presence
        @scheme = params[:scheme].presence
        @identification_private_key = params[:identification_private_key]&.strip.presence
        @private_key = OpenSSL::PKey::RSA.new(identification_private_key_content) if identification_private_key
      end

      attr_reader :scheme

      def public_key
        private_key&.public_key
      end

      def configured?
        private_key && server && api_key
      end

      def encode_data(election_data)
        iat = Time.now.to_i
        jwt_payload = { data: election_data, iat: iat }
        JWT.encode jwt_payload, private_key, "RS256"
      end

      def graphql_client
        @graphql_client ||= Graphlient::Client.new(server,
                                                   headers: {
                                                     "api_key" => api_key
                                                   })
      end

      private

      attr_reader :identification_private_key, :server, :api_key, :private_key

      def identification_private_key_content
        @identification_private_key_content ||= if identification_private_key.starts_with?("-----")
                                                  identification_private_key
                                                else
                                                  File.read(Rails.application.root.join(identification_private_key))
                                                end
      end
    end
  end
end

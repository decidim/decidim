# frozen_string_literal: true

module Decidim
  module Elections
    class BulletinBoardClient
      def initialize(params)
        @server = params[:server].presence
        @api_key = params[:api_key].presence
        @identification_private_key = params[:identification_private_key]&.strip.presence
        @graphql_client = graphql_client
        @private_key = OpenSSL::PKey::RSA.new(identification_private_key_content) if identification_private_key
      end

      def public_key
        private_key&.public_key
      end

      def configured?
        private_key && server && api_key
      end

      def encode_data(setup_election_data)
        JWT.encode setup_election_data, private_key, "RS256"
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

      def graphql_client
        @graphql_client ||= Graphlient::Client.new(server,
                                                   headers: {
                                                     "api_key" => api_key
                                                   })
      end
    end
  end
end

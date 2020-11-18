# frozen_string_literal: true

module Decidim
  module Elections
    class BulletinBoardClient
      def initialize(params)
        @server = params[:server].presence
        @api_key = params[:api_key].presence
        @scheme = params[:scheme].presence
        @authority_name = params[:authority_name].presence
        @number_of_trustees = 0
        @number_of_trustees = params[:number_of_trustees] if params[:number_of_trustees].present?
        @identification_private_key = params[:identification_private_key].presence
        @private_key = identification_private_key_content if identification_private_key
      end

      attr_reader :server, :scheme, :api_key, :number_of_trustees, :authority_name

      def quorum
        return 0 if @scheme.dig(:parameters, :quorum).blank?

        @scheme.dig(:parameters, :quorum)
      end

      def authority_slug
        @authority_slug ||= authority_name.parameterize
      end

      def public_key
        private_key&.export
      end

      def configured?
        private_key && server && api_key
      end

      def encode_data(election_data)
        JWT.encode(election_data, private_key.keypair, "RS256")
      end

      def graphql_client
        @graphql_client ||= Graphlient::Client.new(server,
                                                   headers: {
                                                     "Authorization" => api_key
                                                   })
      end

      private

      attr_reader :identification_private_key, :private_key

      def identification_private_key_content
        @identification_private_key_content ||= Decidim::Elections::JwkUtils.import_private_key(identification_private_key)
      end
    end
  end
end

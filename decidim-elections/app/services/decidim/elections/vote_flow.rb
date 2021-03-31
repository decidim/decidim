# frozen_string_literal: true

module Decidim
  module Elections
    # Service that encapsulates the vote flow used for elections
    class VoteFlow
      def initialize(election, context)
        @election = election
        @context = context
      end

      def valid_token_common_data?
        voter_token_parsed_data[:common] == voter_common_data.as_json
      end

      def valid_voter_id?
        context.params[:vote][:voter_id] == calculate_voter_id(voter_token_parsed_data)
      end

      def valid_token_timestamp?
        voter_token_parsed_data.fetch(:timestamp, 0) > Decidim::Elections.voter_token_expiration_minutes.minutes.ago.to_i
      end

      def voter_id
        @voter_id ||= calculate_voter_id(voter_token_data)
      end

      def calculate_voter_id(data)
        Digest::SHA256.hexdigest(data.slice(:common, :flow).to_json)
      end

      attr_writer :voter_token

      def voter_token
        @voter_token ||= format_token(voter_token_data.to_json)
      end

      def voter_token_parsed_data
        @voter_token_parsed_data ||= JSON.parse(parse_token(voter_token) || "{}").with_indifferent_access
      end

      def format_token(data)
        message_decryptor.encrypt_and_sign(data)
      end

      def parse_token(token)
        token && message_decryptor.decrypt_and_verify(token)
      rescue ActiveSupport::MessageEncryptor::InvalidMessage
        nil
      end

      def voter_token_data
        @voter_token_data = {
          timestamp: Time.current.to_i,
          common: voter_common_data,
          flow: voter_data
        }
      end

      def voter_common_data
        @voter_common_data = {
          secret: Digest::SHA256.hexdigest(Rails.application.credentials.secret_key_base),
          slug: Decidim::Elections.bulletin_board.authority_slug,
          created: election.created_at.to_i,
          election: election.id,
        }
      end

      def message_decryptor
        @message_decryptor ||= ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])
      end
    end
  end
end

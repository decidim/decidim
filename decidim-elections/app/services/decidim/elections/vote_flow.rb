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
        @voter_token ||= message_decryptor.encrypt_and_sign(voter_token_data.to_json)
      end

      def voter_token_parsed_data
        @voter_token_parsed_data ||= JSON.parse(message_decryptor.decrypt_and_verify(voter_token)).with_indifferent_access
      rescue ActiveSupport::MessageEncryptor::InvalidMessage
        {}
      end

      def voter_id_token(a_voter_id = nil)
        @voter_id_token ||= tokenizer.hex_digest(a_voter_id || voter_id)
      end

      private

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
          election: election.id
        }
      end

      def message_decryptor
        @message_decryptor ||= ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])
      end

      def tokenizer
        @tokenizer ||= Decidim::Tokenizer.new(salt: Rails.application.secrets.secret_key_base, length: 10)
      end
    end
  end
end

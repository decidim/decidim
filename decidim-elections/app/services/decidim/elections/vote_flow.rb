# frozen_string_literal: true

module Decidim
  module Elections
    # Service that encapsulates the vote flow used for elections
    class VoteFlow
      def initialize(election, context)
        @election = election
        @context = context
      end

      def voter_id
        @voter_id ||= calculate_voter_id(voter_token_data)
      end

      def voter_id_token(a_voter_id = nil)
        @voter_id_token ||= tokenizer.hex_digest(a_voter_id || voter_id)
      end

      def receive_data(params)
        @received_voter_token = params[:voter_token]
        @received_voter_id = params[:voter_id]

        received_voter_token.present? && received_voter_id.present?
      end

      def voter_token
        @voter_token ||= received_voter_token ||
                         message_encryptor.encrypt_and_sign(
                           voter_token_data.to_json,
                           expires_at: Decidim::Elections.voter_token_expiration_minutes.minutes.from_now
                         )
      end

      def valid_received_data?
        valid_token_common_data? && valid_token_flow_data? && valid_voter_id?
      end

      private

      attr_accessor :received_voter_token, :received_voter_id

      def calculate_voter_id(data)
        Digest::SHA256.hexdigest(data.to_json)
      end

      def valid_voter_id?
        received_voter_id && received_voter_id == calculate_voter_id(received_voter_token_data)
      end

      def valid_token_common_data?
        received_voter_token && received_voter_token_data[:common] == voter_common_data.as_json
      end

      def voter_token_data
        @voter_token_data = {
          common: voter_common_data,
          flow: voter_data
        }
      end

      def voter_common_data
        @voter_common_data = {
          salt: election.salt,
          slug: Decidim::Elections.bulletin_board.authority_slug,
          created: election.created_at.to_i,
          election: election.id
        }
      end

      def received_voter_token_data
        return {} unless verified_received_voter_token

        @received_voter_token_data ||= JSON.parse(verified_received_voter_token).with_indifferent_access
      end

      def verified_received_voter_token
        return @verified_received_voter_token if defined?(@verified_received_voter_token)

        @verified_received_voter_token = begin
          message_encryptor.decrypt_and_verify(received_voter_token)
        rescue ActiveSupport::MessageEncryptor::InvalidMessage
          nil
        end
      end

      def message_encryptor
        @message_encryptor ||= ActiveSupport::MessageEncryptor.new([election.salt].pack("H*"))
      end

      def tokenizer
        @tokenizer ||= Decidim::Tokenizer.new(salt: election.salt, length: 10)
      end
    end
  end
end

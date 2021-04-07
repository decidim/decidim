# frozen_string_literal: true

module Decidim
  module Votings
    # A command to send the access code
    class SendAccessCode < Rectify::Command
      def initialize(datum)
        @datum = datum
      end

      # Executes the command. Broadcast this events:
      # - :invalid when params are missing
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless send_access_code

        send_access_code
      end

      private

      attr_reader :datum

      def send_access_code
        AccessCodeMailer.send_access_code(datum).deliver_later
      end
    end
  end
end

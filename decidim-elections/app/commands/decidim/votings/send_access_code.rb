# frozen_string_literal: true

module Decidim
  module Votings
    # A command to send the access code
    class SendAccessCode < Decidim::Command
      def initialize(datum, medium)
        @datum = datum
        @medium = medium
      end

      # Executes the command. Broadcast this events:
      # - :invalid when params are missing
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless datum

        send_access_code

        broadcast(:ok)
      end

      private

      attr_reader :datum, :medium

      def send_access_code
        case medium
        when "email"
          AccessCodeMailer.send_access_code(datum).deliver_later
        when "sms"
          sms_gateway.new(datum.mobile_phone_number, access_code).deliver_code
        else
          raise ArgumentError, "Medium parameter is invalid"
        end
      end

      def sms_gateway
        Decidim.sms_gateway_service.to_s.safe_constantize
      end

      def access_code
        @access_code ||= datum.access_code
      end
    end
  end
end

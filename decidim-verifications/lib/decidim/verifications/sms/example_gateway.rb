# frozen_string_literal: true

module Decidim
  module Verifications
    module Sms
      class ExampleGateway
        attr_reader :mobile_phone_number, :code

        def initialize(mobile_phone_number, code)
          @mobile_phone_number = mobile_phone_number
          @code = code
        end

        def deliver_code
          Rails.logger.debug { "Example SMS gateway service, verification code is: #{code}, should have been delivered to #{mobile_phone_number}" }
          true
        end
      end
    end
  end
end

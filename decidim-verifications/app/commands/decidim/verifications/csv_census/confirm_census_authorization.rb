# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      class ConfirmCensusAuthorization < ConfirmUserAuthorization
        def call
          return broadcast(:invalid) unless form.valid?

          Decidim::Authorization.transaction do
            authorization.lock!
            authorization.clear_expired_lock!

            return broadcast(:locked) if authorization.locked_for_confirmation?

            if confirmation_successful?
              authorization.grant!
              authorization.reset_failed_attempts!
              broadcast(:ok)
            else
              authorization.record_failed_attempt!
              broadcast(:invalid)
            end
          end
        end
      end
    end
  end
end

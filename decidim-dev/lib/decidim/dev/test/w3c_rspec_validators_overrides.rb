# frozen_string_literal: true

# This allows us to dynamically load the validator URL from the ENV.
module W3cRspecValidators
  class Config
    def self.get
      @config ||= {
        w3c_service_uri: ENV.fetch("VALIDATOR_HTML_URI", "https://validator.w3.org/nu/")
      }.stringify_keys
    end
  end
end

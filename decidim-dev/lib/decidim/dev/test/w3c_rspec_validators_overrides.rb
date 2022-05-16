# frozen_string_literal: true

# This is a temporary fix to ignore some HTML/CSS validation issues with the
# Decidim HTML validation process.
#
# See: https://github.com/decidim/decidim/issues/8596
# Related: https://github.com/w3c/css-validator/issues/355
module W3CValidators
  class NuValidator
    protected

    alias validate_nu validate unless method_defined?(:validate_nu)

    def validate(options) # :nodoc:
      filter_results(validate_nu(options))
    end

    def ignore_errors
      @ignore_errors ||= [
        "CSS: “--content-height”: One operand must be a number."
      ]
    end

    def filter_results(results)
      messages = results.instance_variable_get(:@messages)
      messages.delete_if do |msg|
        msg.is_error? && ignore_errors.include?(msg.message)
      end
      results.instance_variable_set(:@validity, messages.none?(&:is_error?))

      results
    end
  end
end

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

# frozen_string_literal: true

# This is a temporary fix to ignore some HTML/CSS validation issues with the
# Decidim HTML validation process.
#
# See: https://github.com/decidim/decidim/pull/10014
# Related:
# - https://github.com/rails/rails/issues/46405
# - https://github.com/foundation/foundation-sites/pull/12496
module W3CValidators
  class NuValidator
    protected

    alias validate_nu validate unless method_defined?(:validate_nu)

    def validate(options) # :nodoc:
      filter_results(validate_nu(options))
    end

    def ignore_errors
      @ignore_errors ||= [
        "An “input” element with a “type” attribute whose value is “hidden” must not have an “autocomplete” attribute whose value is “on” or “off”.",
        "An “input” element with a “type” attribute whose value is “hidden” must not have any “aria-*” attributes."
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

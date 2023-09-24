# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Headers
    module ContentSecurityPolicy
      extend ActiveSupport::Concern

      included do
        def content_security_policy
          @content_security_policy ||= Decidim::ContentSecurityPolicy.new(current_organization, Decidim.content_security_policies_extra)
        end

        after_action :append_content_security_policy_headers
      end

      private

      def append_content_security_policy_headers
        response.headers["Content-Security-Policy"] = content_security_policy.output_policy
      end
    end
  end
end

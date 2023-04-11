# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Elections
    module ContentSecurityPolicy
      extend ActiveSupport::Concern

      included do
        before_action :append_csp_directives
      end

      private

      def append_csp_directives
        return unless Decidim::Elections.bulletin_board.configured?

        content_security_policy.append_csp_directive("connect-src", Decidim::Elections.bulletin_board.bulletin_board_server)
      end
    end
  end
end

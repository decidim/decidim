# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module DisableRedirectionToExternalHost
    extend ActiveSupport::Concern

    included do
      def redirect_back(fallback_location:, allow_other_host: true, **args) # rubocop:disable Lint/UnusedMethodArgument
        super fallback_location:, allow_other_host: Decidim.allow_open_redirects, **args
      end
    end
  end
end

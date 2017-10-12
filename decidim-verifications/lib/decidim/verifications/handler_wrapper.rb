# frozen_string_literal: true

require_relative "base_wrapper"

module Decidim
  module Verifications
    class HandlerWrapper < BaseWrapper
      def key
        name.underscore
      end

      def type
        "direct"
      end

      def root_path(redirect_url: nil)
        decidim.new_authorization_path(handler: name, redirect_url: redirect_url)
      end
    end
  end
end

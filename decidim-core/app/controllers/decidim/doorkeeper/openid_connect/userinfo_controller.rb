# frozen_string_literal: true

module Decidim
  module Doorkeeper
    module OpenidConnect
      # Custom Doorkeeper OpenID Connect controller to avoid namespace problems,
      # following the same pattern as the controllers in the parent directory.
      class UserinfoController < ::Doorkeeper::OpenidConnect::UserinfoController
      end
    end
  end
end

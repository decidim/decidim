# frozen_string_literal: true

module Decidim
  module Doorkeeper
    # Custom Doorkeeper TokenInfoController to avoid namespace problems.
    class TokenInfoController < ::Doorkeeper::TokenInfoController
    end
  end
end

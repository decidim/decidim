# frozen_string_literal: true

module Decidim
  module Doorkeeper
    # Custom Doorkeeper TokensController to avoid namespace problems.
    class TokensController < ::Doorkeeper::TokensController
    end
  end
end

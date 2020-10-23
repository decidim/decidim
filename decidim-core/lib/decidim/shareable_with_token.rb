# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the components needed when you want a model to be publicly shareable skipping authentication,
  # using a token with an expiration time.
  #
  module ShareableWithToken
    extend ActiveSupport::Concern

    included do
      has_many :share_tokens,
               class_name: "Decidim::ShareToken",
               foreign_type: "token_for_type",
               inverse_of: :token_for,
               as: :token_for,
               dependent: :destroy

      # Override this method in the included class with the public url for the shareable resource
      def shareable_url(_share_token)
        raise NotImplementedError
      end
    end
  end
end

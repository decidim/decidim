# frozen_string_literal: true

module Decidim
  module Admin
    class ShareTokenForm < Decidim::Form
      include TranslatableAttributes

      attribute :token, String
      attribute :expires_at, Decidim::Attributes::TimeWithZone

      validates :token, presence: true

      def token
        attributes[:token].to_s.upcase
      end
    end
  end
end

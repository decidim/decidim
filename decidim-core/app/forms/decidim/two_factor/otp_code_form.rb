# frozen_string_literal: true

module Decidim
  module TwoFactor
    # A six-digit one-time code typed to confirm an enrollment.
    class OtpCodeForm < Decidim::Form
      mimic :challenge

      attribute :code, String

      validates :code, presence: true, format: { with: /\A\d{6}\z/, allow_blank: true }

      def code
        super.to_s.gsub(/\s+/, "")
      end
    end
  end
end

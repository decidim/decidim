# frozen_string_literal: true

require "rqrcode"

module Decidim
  module TwoFactor
    # Helpers for the second-factor setup pages.
    module SetupHelper
      def two_factor_usage(authenticator, description = nil)
        added = description || t("decidim.two_factor.setup.added_on", date: l(authenticator.confirmed_at.to_date, format: :decidim_short))
        return added if authenticator.last_used_at.blank?

        "#{added}. #{t("decidim.two_factor.setup.last_used_on", date: l(authenticator.last_used_at.to_date, format: :decidim_short))}"
      end

      # Every option is passed explicitly: the defaults differ between the rqrcode versions supported by Decidim.
      def totp_qr_code_data_uri(authenticator)
        svg = RQRCode::QRCode.new(authenticator.provisioning_uri).as_svg(
          offset: 24,
          color: "000",
          fill: "fff",
          module_size: 6,
          shape_rendering: "crispEdges",
          standalone: true,
          use_path: true,
          viewbox: false
        )

        "data:image/svg+xml;base64,#{Base64.strict_encode64(svg)}"
      end

      def totp_manual_key(authenticator)
        authenticator.secret.scan(/.{1,4}/).join(" ")
      end
    end
  end
end

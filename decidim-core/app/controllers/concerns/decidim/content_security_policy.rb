# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ContentSecurityPolicy
    extend ActiveSupport::Concern

    included do
      before_action :set_content_security_policy
    end

    private

    def set_content_security_policy
      # return unless current_organization
      #
      # policy = current_organization.content_security_policy
      # return unless policy

      policy = [
        "default-src #{csp_default_src}",
        "img-src *",
        "media-src #{csp_media_src}",
        "script-src #{csp_script_src}",
        "style-src #{csp_style_src}",
        "frame-src #{csp_frame_src}",
        "font-src #{csp_font_src}",
        "connect-src #{csp_connect_src}",
      ]

      response.headers["Content-Security-Policy"] = policy.join("; ")
    end

    def csp_media_src
      Decidim.csp_media_src
    end

    def csp_frame_src
      "'self' #{Decidim.csp_frame_src}"
    end

    def csp_font_src
      "'self' #{Decidim.csp_font_src}"
    end

    def csp_style_src
      "'self' #{Decidim.csp_style_src}"
    end

    def csp_connect_src
      "'self' #{Decidim.csp_connect_src}"
    end

    def csp_default_src
      "'self' 'unsafe-inline' #{Decidim.csp_default_src}"
    end

    def csp_script_src
      "'self' 'unsafe-inline' #{Decidim.csp_script_src}"
    end
  end
end

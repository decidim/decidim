# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ContentSecurityPolicy
    extend ActiveSupport::Concern

    included do
      after_action :set_content_security_policy
    end

    private

    def set_content_security_policy
      return unless respond_to?(:current_organization)
      return unless current_organization

      policy = [
        ["default-src", csp_default_src],
        ["img-src", csp_img_src],
        ["media-src", csp_media_src],
        ["script-src", csp_script_src],
        ["style-src", csp_style_src],
        ["frame-src", csp_frame_src],
        ["font-src", csp_font_src],
        ["connect-src", csp_connect_src],
      ].map do |directive, value|
        value = value.split(" ").uniq.join(" ")
        "#{directive} #{value}"
      end
      response.headers["Content-Security-Policy"] = policy.join("; ")
    end

    def csp
      current_organization.content_security_policy
    end

    %w(img_src media_src frame_src font_src style_src connect_src default_src script_src).each do |csp_type|
      define_method "csp_#{csp_type}" do
        "#{Decidim.send("csp_#{csp_type}")} #{csp.fetch(csp_type, '')} #{additional_csp.fetch(csp_type, []).join(" ")}"
      end

      define_method "add_csp_#{csp_type}" do |value|
        additional_csp[csp_type] ||= []
        additional_csp[csp_type] << value
      end
    end

    def additional_csp
      @additional_csp ||= {}
    end
  end
end

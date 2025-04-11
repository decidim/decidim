# frozen_string_literal: true

module Decidim
  module QrCodeHelper
    include Decidim::ShortLinkHelper

    def resource_url
      @resource_url ||= (resource_name ? short_url(route_name: resource_name, params: processed_params) : decidim_meta_url)
    end

    def qr_code
      @qr_code ||= RQRCode::QRCode.new(resource_url.to_s)
    end

    def resource_name
      return "budget_project" if Decidim.module_installed?(:budgets) && resource.is_a?(Decidim::Budgets::Project)

      resource.class.name.demodulize.underscore
    end

    def qr_code_image
      Base64.encode64(qr_code.as_png(size: 500).to_s).gsub("\n", "")
    end
  end
end

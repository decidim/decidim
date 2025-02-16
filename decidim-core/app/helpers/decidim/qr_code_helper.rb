# frozen_string_literal: true

module Decidim
  module QrCodeHelper
    include Decidim::ShortLinkHelper

    def resource_url
      @resource_url ||= (resource_name ? short_url(route_name: resource_name, params:) : decidim_meta_url)
    end

    def qr_code
      @qr_code ||= RQRCode::QRCode.new(resource_url.to_s)
    end

    def resource_name
      return "budget_project" if resource.is_a?(Decidim::Budgets::Project)

      resource.class.name.demodulize.underscore
    end
  end
end

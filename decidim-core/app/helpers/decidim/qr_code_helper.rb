# frozen_string_literal: true

module Decidim
  module QrCodeHelper
    include Decidim::ShortLinkHelper

    def resource_url
      @resource_url ||= (resource_name ? short_url(route_name: resource_name, params: local_params) : decidim_meta_url)
    end

    def qr_code
      @qr_code ||= RQRCode::QRCode.new(resource_url.to_s)
    end

    def local_params
      return processed_params.merge(budget_id: resource.decidim_budgets_budget_id) if project?

      processed_params
    end

    def resource_name
      return "budget_project" if project?

      resource.class.name.demodulize.underscore
    end

    def qr_code_image
      Base64.encode64(qr_code.as_png(size: 500).to_s).gsub("\n", "")
    end

    private

    def project?
      Decidim.module_installed?(:budgets) && resource.is_a?(Decidim::Budgets::Project)
    end
  end
end

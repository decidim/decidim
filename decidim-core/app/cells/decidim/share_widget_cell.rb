# frozen_string_literal: true

require "rqrcode"

module Decidim
  class ShareWidgetCell < Decidim::ViewModel
    include Decidim::ShortLinkHelper
    include Decidim::SocialShareButtonHelper

    def show
      render
    end

    private

    def resource_url
      @resource_url ||= (resource_name ? short_url(route_name: resource_name, params:) : decidim_meta_url)
    end

    def qr_code
      @qr_code ||= RQRCode::QRCode.new(resource_url.to_s)
    end

    def resource_name
      return "budget_project" if model.is_a?(Decidim::Budgets::Project)

      model.class.name.demodulize.underscore
    end
  end
end

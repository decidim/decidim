# frozen_string_literal: true

require "rqrcode"

module Decidim
  class InvalidUrlError < StandardError; end

  class QrController < Decidim::ApplicationController
    include Decidim::OrganizationHelper
    include Decidim::QrCodeHelper

    helper_method :resource, :qr_code, :qr_code_image

    layout false

    def show
      respond_to do |format|
        format.html
        format.png { send_data(qr_code.as_png(size: 480), filename: "qr-#{organization_name}-#{sluggified_title}.png") }
      end
    end

    private
    def resource
      @resource ||= GlobalID::Locator.locate_signed(params[:resource])
    end

    def sluggified_title
      [
        resource.title.parameterize,
        resource.id
      ].join("-")
    end
  end
end

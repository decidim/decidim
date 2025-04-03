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
        format.png { send_data(qr_code.as_png(size: 500), filename: "qr-#{organization_name}-#{parametrized_title}.png") }
      end
    end

    # needs to be public so that short link works
    def current_component = resource.try(:component)

    # needs to be public so that short link works
    def current_participatory_space
      return resource if resource.is_a?(Decidim::Participable)

      resource.try(:participatory_space)
    end

    private

    def processed_params
      return {} if resource.is_a?(Decidim::Participable)

      {
        participatory_process_slug: current_participatory_space.slug,
        component_id: current_component&.id&.to_s,
        id: resource.id.to_s
      }.with_indifferent_access
    end

    def resource
      @resource ||= GlobalID::Locator.locate_signed(params[:resource])
    end

    def parametrized_title
      [
        resource.presenter.title(html_escape: true).parameterize,
        resource.id
      ].join("-")
    end
  end
end

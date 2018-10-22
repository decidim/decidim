# frozen_string_literal: true

module Decidim
  # This controller serves static pages using HighVoltage.
  class PagesController < Decidim::ApplicationController
    layout "layouts/decidim/application"

    helper_method :page, :pages
    helper CtaButtonHelper
    helper Decidim::SanitizeHelper
    skip_before_action :store_current_location

    before_action :set_default_request_format

    def index
      enforce_permission_to :read, :public_page
      redirect_to action: :show, id: pages.first.slug
    end

    def show
      enforce_permission_to :read, :public_page, page: page
      raise ActionController::RoutingError, "Not Found" unless page
    end

    def page
      @page ||= current_organization.static_pages.find_by(slug: params[:id])
    end

    private

    def set_default_request_format
      request.format = :html
    end

    def pages
      @pages ||= current_organization.static_pages
    end
  end
end

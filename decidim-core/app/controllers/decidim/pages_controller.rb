# frozen_string_literal: true

module Decidim
  # This controller serves static pages using HighVoltage.
  class PagesController < Decidim::ApplicationController
    layout "layouts/decidim/application"

    helper_method :page, :stats
    helper CtaButtonHelper
    helper Decidim::SanitizeHelper
    skip_before_action :store_current_location

    def index
      enforce_permission_to :read, :public_page
      @pages = current_organization.static_pages.sorted_by_i18n_title
    end

    def show
      enforce_permission_to :read, :public_page, page: page
      if params[:id] == "home"
        render :home
      elsif page
        render :decidim_page
      else
        raise ActionController::RoutingError, "Not Found"
      end
    end

    def page
      @page ||= current_organization.static_pages.find_by(slug: params[:id])
    end
  end
end

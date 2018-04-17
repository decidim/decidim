# frozen_string_literal: true

require_dependency "decidim/page_finder"

module Decidim
  # This controller serves static pages using HighVoltage.
  class PagesController < Decidim::ApplicationController
    include HighVoltage::StaticPage

    layout "layouts/decidim/application"

    delegate :page, to: :page_finder
    helper_method :page, :stats
    helper CtaButtonHelper
    helper Decidim::SanitizeHelper
    skip_before_action :store_current_location

    def index
      enforce_permission_to :read, :public_page
      @pages = current_organization.static_pages.all.to_a.sort do |a, b|
        a.title[I18n.locale.to_s] <=> b.title[I18n.locale.to_s]
      end
    end

    def page_finder
      @page_finder ||= Decidim::PageFinder.new(params[:id], current_organization)
    end

    private

    def stats
      @stats ||= HomeStatsPresenter.new(organization: current_organization)
    end
  end
end

# frozen_string_literal: true
require_dependency "decidim/application_controller"
require_dependency "decidim/page_finder"

module Decidim
  # This controller serves static pages using HighVoltage.
  class PagesController < ApplicationController
    include HighVoltage::StaticPage

    authorize_resource :public_pages, class: false
    delegate :page, to: :page_finder
    helper_method :page

    def page_finder
      @page_finder ||= Decidim::PageFinder.new(params[:id], current_organization)
    end
  end
end

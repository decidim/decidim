# frozen_string_literal: true
require_dependency "decidim/application_controller"
require_dependency "decidim/page_finder"

module Decidim
  # This controller serves static pages using HighVoltage.
  class PagesController < ApplicationController
    include HighVoltage::StaticPage

    layout "layouts/decidim/application"

    authorize_resource :public_pages, class: false
    delegate :page, to: :page_finder
    helper_method :page, :participatory_processes

    def page_finder
      @page_finder ||= Decidim::PageFinder.new(params[:id], current_organization)
    end

    def participatory_processes
      @participatory_processes ||= current_organization.participatory_processes.includes(:active_step).published.promoted
    end
  end
end

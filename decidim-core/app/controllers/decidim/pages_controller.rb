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
    helper_method :page, :highlighted_participatory_processes, :promoted_participatory_processes, :participatory_processes, :users

    def page_finder
      @page_finder ||= Decidim::PageFinder.new(params[:id], current_organization)
    end

    def users
      @users ||= Decidim::User.where(organization: current_organization)
    end

    # This should be deleted once the statistics are done properly.
    def participatory_processes
      @processes ||= OrganizationParticipatoryProcesses.new(current_organization) | PublicParticipatoryProcesses.new
    end

    def highlighted_participatory_processes
      @promoted_processes ||= OrganizationParticipatoryProcesses.new(current_organization) | PublicParticipatoryProcesses.new | HighlightedParticipatoryProcesses.new
    end
  end
end

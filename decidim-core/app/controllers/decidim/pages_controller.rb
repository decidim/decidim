# frozen_string_literal: true

require_dependency "decidim/page_finder"

module Decidim
  # This controller serves static pages using HighVoltage.
  class PagesController < Decidim::ApplicationController
    include HighVoltage::StaticPage

    layout "layouts/decidim/application"

    authorize_resource :public_pages, class: false
    delegate :page, to: :page_finder
    helper_method :page, :promoted_participatory_processes, :highlighted_participatory_processes, :stats

    def index
      @pages = current_organization.static_pages.all.to_a.sort do |a, b|
        a.title[I18n.locale.to_s] <=> b.title[I18n.locale.to_s]
      end
    end

    def page_finder
      @page_finder ||= Decidim::PageFinder.new(params[:id], current_organization)
    end

    def promoted_participatory_processes
      @promoted_participatory_processes ||=
        ParticipatoryProcesses::OrganizationPrioritizedParticipatoryProcesses.new(current_organization) | ParticipatoryProcesses::PromotedParticipatoryProcesses.new
    end

    def highlighted_participatory_processes
      @highlighted_participatory_processes ||=
        ParticipatoryProcesses::OrganizationPublishedParticipatoryProcesses.new(current_organization) | ParticipatoryProcesses::HighlightedParticipatoryProcesses.new
    end

    private

    def stats
      @stats ||= HomeStatsPresenter.new(organization: current_organization)
    end
  end
end

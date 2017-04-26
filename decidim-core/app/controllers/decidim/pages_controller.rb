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
    helper_method :page, :promoted_participatory_processes, :highlighted_participatory_processes, :participatory_processes,
                  :users, :accepted_proposals_count, :results_count, :proposals_count, :votes_count, :meetings_count

    def index
      @pages = current_organization.static_pages.all.to_a.sort do |a, b|
        a.title[I18n.locale.to_s] <=> b.title[I18n.locale.to_s]
      end
    end

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

    def promoted_participatory_processes
      @promoted_processes ||= participatory_processes | PromotedParticipatoryProcesses.new
    end

    def highlighted_participatory_processes
      @promoted_processes ||= OrganizationParticipatoryProcesses.new(current_organization) | HighlightedParticipatoryProcesses.new
    end

    private

    def accepted_proposals_count
      Decidim.stats_for(:accepted_proposals_count, published_features)
    end

    def proposals_count
      Decidim.stats_for(:proposals_count, published_features)
    end

    def results_count
      Decidim.stats_for(:results_count, published_features)
    end

    def votes_count
      Decidim.stats_for(:votes_count, published_features)
    end

    def meetings_count
      Decidim.stats_for(:meetings_count, published_features)
    end

    def published_features
      @published_features ||= Feature.where(participatory_process: ParticipatoryProcess.published)
    end
  end
end

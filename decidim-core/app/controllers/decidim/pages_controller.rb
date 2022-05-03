# frozen_string_literal: true

module Decidim
  # This controller serves static pages using HighVoltage.
  class PagesController < Decidim::ApplicationController
    layout "layouts/decidim/application"

    helper_method :page, :pages, :privacy_policy_content_blocks
    helper CtaButtonHelper
    helper Decidim::SanitizeHelper

    before_action :set_default_request_format

    def index
      enforce_permission_to :read, :public_page
      @topics = StaticPageTopic.where(organization: current_organization)
      @orphan_pages = StaticPage.where(topic: nil, organization: current_organization)
    end

    def show
      @page = current_organization.static_pages.find_by!(slug: params[:id])
      enforce_permission_to :read, :public_page, page: @page
      @topic = @page.topic
      @pages = @topic&.pages
    end

    private

    def set_default_request_format
      request.format = :html
    end

    def privacy_policy_content_blocks
      @privacy_policy_content_blocks ||= Decidim::ContentBlock.published
                                                              .for_scope(:privacy_policy, organization: current_organization)
                                                              .reject { |content_block| content_block.manifest.nil? }
    end
  end
end

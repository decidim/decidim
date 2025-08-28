# frozen_string_literal: true

module Decidim
  # This controller serves static pages using HighVoltage.
  class PagesController < Decidim::ApplicationController
    layout "layouts/decidim/application"

    helper_method :page, :pages, :page_content_blocks
    helper Decidim::SanitizeHelper

    before_action :legacy_redirect, :set_default_request_format

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

    def legacy_redirect
      return redirect_to decidim.page_path("terms-of-service") if params[:id] == "terms-and-conditions"
    end

    def set_default_request_format
      request.format = :html
    end

    def page_content_blocks
      return [] unless Decidim.page_blocks.include?(@page.slug)

      @page_content_blocks ||= Decidim::ContentBlock.published
                                                    .for_scope(:static_page, organization: current_organization)
                                                    .where(scoped_resource_id: @page.id)
                                                    .reject { |content_block| content_block.manifest.nil? }
    end
  end
end

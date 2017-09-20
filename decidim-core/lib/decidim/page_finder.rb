# frozen_string_literal: true

module Decidim
  # A custom implementation for HighVoltage so we can correctly find which page
  # to render. We need this because we allow rendering pages with content from
  # the database (with Decidim::Page) but also fallback to a template if it
  # exists.
  class PageFinder < HighVoltage::PageFinder
    DECIDIM_PAGE_TEMPLATE = "decidim_page"

    # Initializes the finder.
    #
    # page_id - A String with the id or slug of the page to render.
    # organization - A Decidim::Organization to look for pages in.
    def initialize(page_id, organization)
      @page_id = page_id
      @organization = organization
    end

    # Finds a Decidim::Page by slug.
    #
    # Returns a Decidim::Page or nil.
    def page
      @page ||= organization.static_pages.where(slug: page_id).first
    end

    private

    attr_reader :organization

    # Overwrite HighVoltage::PageFinder method to return a specific template
    # when we need to render a Decidim::Page.
    #
    # Returns a String.
    def clean_path
      return super if page.blank?

      DECIDIM_PAGE_TEMPLATE
    end

    # Overwrite HighVoltage::PageFinder method to not allow rendering the
    # template used to render Decidim::Pages without a page.
    #
    # Returns a Boolean.
    def invalid_page_id?(id)
      super || id == DECIDIM_PAGE_TEMPLATE
    end
  end
end

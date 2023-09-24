# frozen_string_literal: true

require "cell/partial"

module Decidim
  # This cell renders the pages in the footer. It has 2 types of pages with
  # different layouts:
  # * Pages of topics: To appear in the footer both the topic and the page must
  #   be marked to appear in footer. The topic will be shown as the title and
  #   all the pages marked will appear below
  # * Pages without topic. The pages marked to appear in footer which do not
  #   belong to a topic will be shown as a list
  #
  # Example:
  #
  #    cell("decidim/footer_pages", :topics)
  class FooterPagesCell < Decidim::ViewModel
    include ApplicationHelper

    OPTIONS = [:topics, :pages].freeze

    def show
      return unless model.present? && OPTIONS.include?(model.to_sym)
      return if pages.blank?

      render model
    end

    private

    def pages
      @pages = case model.to_sym
               when :topics
                 organization_topics
               when :pages
                 organization_pages
               end
    end

    def organization_pages
      current_organization
        .static_pages_accessible_for(current_user)
        .where(show_in_footer: true, topic_id: nil)
        .where.not(slug: "terms-and-conditions").map do |page|
        { title: translated_attribute(page.title), path: decidim.page_path(page) }
      end
    end

    def organization_topics
      current_organization.static_page_topics.where(show_in_footer: true).map do |topic|
        next if (topic_pages = topic.accessible_pages_for(current_user).where(show_in_footer: true)).blank?

        {
          title: translated_attribute(topic.title),
          pages: topic_pages.map do |page|
            { title: translated_attribute(page.title), path: decidim.page_path(page) }
          end
        }
      end.compact
    end

    def page_item(page_data, opts = {})
      content_tag(:li, **opts.slice(:class)) do
        link_to page_data[:title], page_data[:path]
      end
    end
  end
end

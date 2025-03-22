# frozen_string_literal: true

require "cell/partial"

module Decidim
  # Topics and their corresponding pages are mapped out to the footer
  # of the layout.
  #
  #  Example:
  #
  #   cell("decidim/footer_topics", nil)
  #
  class FooterTopicsCell < Decidim::ViewModel
    def show
      return if topics.blank?

      render
    end

    private

    def topics
      @topics ||= current_organization.static_page_topics.where(show_in_footer: true).map do |topic|
        next if topic.pages.empty?

        {
          title: decidim_escape_translated(topic.title),
          path: decidim.page_path(topic.pages.first, locale: current_locale)
        }
      end.compact
    end

    def topic_item(page_data, opts = {})
      content_tag(:li, **opts.slice(:class)) do
        link_to page_data[:title], page_data[:path]
      end
    end
  end
end

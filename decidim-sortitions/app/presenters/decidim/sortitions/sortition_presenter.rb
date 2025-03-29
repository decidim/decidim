# frozen_string_literal: true

module Decidim
  module Sortitions
    class SortitionPresenter < Decidim::ResourcePresenter
      def sortition
        __getobj__
      end

      def title(links: false, html_escape: false, all_locales: false)
        return unless sortition

        super(sortition.title, links, html_escape, all_locales)
      end
    end
  end
end

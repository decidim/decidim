# frozen_string_literal: true

module Decidim
  module Sortitions
    class SortitionPresenter < Decidim::ResourcePresenter
      def sortition
        __getobj__
      end

      def title(links: nil, html_escape: false, all_locales: false)
        return unless sortition

        raise "Links have been set" unless links.nil?

        super(sortition.title, html_escape, all_locales)
      end
    end
  end
end

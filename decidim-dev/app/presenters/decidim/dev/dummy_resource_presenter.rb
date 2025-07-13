# frozen_string_literal: true

module Decidim
  module Dev
    class DummyResourcePresenter < Decidim::ResourcePresenter
      def title(links: false, html_escape: false, all_locales: false)
        return unless __getobj__

        super(__getobj__.title, links, html_escape, all_locales)
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Dev
    class DummyResourcePresenter < Decidim::ResourcePresenter
      def title(links: nil, html_escape: false, all_locales: false)
        return unless __getobj__

        raise "Links have been set" unless links.nil?

        super(__getobj__.title, nil, html_escape, all_locales)
      end
    end
  end
end

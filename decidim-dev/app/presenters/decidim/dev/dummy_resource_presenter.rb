# frozen_string_literal: true

module Decidim
  module Dev
    class DummyResourcePresenter < Decidim::ResourcePresenter
      def title(html_escape: false, all_locales: false)
        return unless __getobj__

        super(__getobj__.title, html_escape, all_locales)
      end
    end
  end
end

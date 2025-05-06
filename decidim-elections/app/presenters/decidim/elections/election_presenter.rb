# frozen_string_literal: true

module Decidim
  module Elections
    class ElectionPresenter < Decidim::ResourcePresenter
      include Decidim::ResourceHelper
      include ActionView::Helpers::UrlHelper
      include Decidim::SanitizeHelper

      def election
        __getobj__
      end

      def election_path
        return nil unless election

        Decidim::ResourceLocatorPresenter.new(election).path
      end

      def title(links: false, html_escape: false, all_locales: false)
        return unless election

        super(election.title, links, html_escape, all_locales)
      end

      def description(links: false, extras: true, strip_tags: false, all_locales: false)
        return unless election

        content_handle_locale(election.description, all_locales, extras, links, strip_tags)
      end
    end
  end
end

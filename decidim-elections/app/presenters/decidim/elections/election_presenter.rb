# frozen_string_literal: true

module Decidim
  module Elections
    #
    # Decorator for election
    #
    class ElectionPresenter < SimpleDelegator
      include Decidim::SanitizeHelper
      include Decidim::TranslatableAttributes

      def election
        __getobj__
      end

      def title
        content = translated_attribute(election.title)
        decidim_html_escape(content)
      end

      def description(strip_tags: false)
        content = translated_attribute(election.description)
        content = strip_tags(content) if strip_tags
        content
      end
    end
  end
end

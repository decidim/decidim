# frozen_string_literal: true

module Decidim
  module Debates
    #
    # Decorator for debates
    #
    class DebatePresenter < SimpleDelegator
      include Decidim::SanitizeHelper
      include Decidim::TranslatableAttributes

      def debate
        __getobj__
      end

      def author
        @author ||= if official?
                      Decidim::Debates::OfficialAuthorPresenter.new
                    elsif user_group
                      Decidim::UserGroupPresenter.new(user_group)
                    else
                      Decidim::UserPresenter.new(super)
                    end
      end

      def title
        content = translated_attribute(debate.title)
        decidim_html_escape(content)
      end

      def description(strip_tags: false)
        content = translated_attribute(debate.description)
        content = strip_tags(content) if strip_tags
        content
      end
    end
  end
end

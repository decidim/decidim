# frozen_string_literal: true

module Decidim
  module Debates
    #
    # Decorator for debates
    #
    class DebatePresenter < SimpleDelegator
      include Decidim::TranslationsHelper
      include Decidim::ResourceHelper
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

      def title(links: false)
        text = translated_attribute(debate.title)
        text = decidim_html_escape(text)
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(text)
        renderer.render(links: links).html_safe
      end

      def description(strip_tags: false, links: false)
        text = translated_attribute(debate.description)
        text = strip_tags(text) if strip_tags
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(text)
        text = renderer.render(links: links).html_safe
        text = Decidim::ContentRenderers::LinkRenderer.new(text).render if links
        text
      end

      def handle_locales(content, all_locales)
        if all_locales
          content.each_with_object({}) do |(locale, string), parsed_content|
            parsed_content[locale] = yield(string)
          end
        else
          yield(translated_attribute(content))
        end
      end
    end
  end
end

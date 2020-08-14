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

      def title(links: false, all_locales: false)
        return unless debate

        handle_locales(debate.title, all_locales) do |content|
          renderer = Decidim::ContentRenderers::HashtagRenderer.new(decidim_html_escape(content))
          renderer.render(links: links).html_safe
        end
      end

      def description(strip_tags: false, links: false, all_locales: false)
        return unless debate

        handle_locales(debate.description, all_locales) do |content|
          renderer = Decidim::ContentRenderers::HashtagRenderer.new(decidim_sanitize(content, strip_tags: strip_tags))
          renderer.render(links: links).html_safe
        end
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

# frozen_string_literal: true

module Decidim
  # A presenter to render attributes for resources
  class ResourcePresenter < SimpleDelegator
    include Decidim::TranslatableAttributes
    include Decidim::SanitizeHelper

    def title(resource_title, links, html_escape, all_locales, extras: true)
      handle_locales(resource_title, all_locales) do |content|
        content = decidim_html_escape(content) if html_escape

        renderer = Decidim::ContentRenderers::HashtagRenderer.new(content)
        renderer.render(links:, extras:).html_safe
      end
    end

    def handle_locales(content, all_locales, &block)
      if all_locales
        content.each_with_object({}) do |(key, value), parsed_content|
          parsed_content[key] = if key == "machine_translations"
                                  handle_locales(value, all_locales, &block)
                                else
                                  block.call(value)
                                end
        end
      else
        yield(translated_attribute(content))
      end
    end
  end
end

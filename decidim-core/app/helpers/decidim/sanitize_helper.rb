# frozen_string_literal: true

module Decidim
  # Helper that provides methods to render order selector and links
  module SanitizeHelper
    def self.included(base)
      base.include ActionView::Helpers::SanitizeHelper
      base.include ActionView::Helpers::TagHelper
      base.include Decidim::TranslatableAttributes
    end

    # Public: It sanitizes a user-inputted string with the
    # `Decidim::UserInputScrubber` scrubber, so that video embeds work
    # as expected. Uses Rails' `sanitize` internally.
    #
    # html - A string representing user-inputted HTML.
    #
    # Returns an HTML-safe String.
    def decidim_sanitize(html, options = {})
      scrubber = options[:scrubber] || Decidim::UserInputScrubber.new
      if options[:strip_tags]
        strip_tags sanitize(html, scrubber:)
      else
        sanitize(html, scrubber:)
      end
    end

    def decidim_sanitize_admin(html, options = {})
      decidim_sanitize(html, { scrubber: Decidim::AdminInputScrubber.new }.merge(options))
    end

    def decidim_sanitize_newsletter(html, options = {})
      if options[:strip_tags]
        strip_tags sanitize(html, scrubber: Decidim::NewsletterScrubber.new)
      else
        sanitize(html, scrubber: Decidim::NewsletterScrubber.new)
      end
    end

    # Converts the blob and blob variant references to blob URLs.
    def decidim_rich_text(html, **)
      renderer = Decidim::ContentProcessor.renderer_klass(:blob).constantize.new(html)
      renderer.render(**)
    end

    def decidim_sanitize_editor(html, options = {})
      content_tag(:div, decidim_sanitize(html, options), class: %w(rich-text-display))
    end

    def decidim_sanitize_editor_admin(html, options = {})
      html = Decidim::IframeDisabler.new(html, options).perform
      decidim_sanitize_editor(
        decidim_rich_text(html),
        { scrubber: Decidim::AdminInputScrubber.new }.merge(options)
      )
    end

    def decidim_html_escape(text)
      ERB::Util.unwrapped_html_escape(text.to_str)
    end

    def decidim_url_escape(text)
      decidim_html_escape(text).sub(/^\s*javascript:/, "")
    end

    def decidim_sanitize_translated(text)
      decidim_sanitize(translated_attribute(text))
    end

    def decidim_escape_translated(text)
      decidim_html_escape(translated_attribute(text))
    end

    private

    # Maintains the paragraphs and lists separations with their bullet points and
    # list numberings where appropriate.
    #
    # Returns a String.
    def sanitize_text(text)
      add_line_feeds(sanitize_ordered_lists(sanitize_unordered_lists(text)))
    end

    def sanitize_unordered_lists(text)
      text.gsub(%r{(\n+)?(</?li>)(\n+)?}, "\\2")
          .gsub(%r{(?=.*</ul>)(?!.*?<li>.*?</ol>.*?</ul>)<li>}) { |li| "#{li}• " }
    end

    def sanitize_ordered_lists(text)
      i = 0

      text.gsub(%r{(\n+)?(</?li>)(\n+)?}, "\\2")
          .gsub(%r{(?=.*</ol>)(?!.*?<li>.*?</ul>.*?</ol>)<li>}) do |li|
        i += 1

        li + "#{i}. "
      end
    end

    def add_line_feeds_to_paragraphs(text)
      text.gsub("</p>") { |p| "#{p}\n\n" }
    end

    def add_line_feeds_to_list_items(text)
      text.gsub("</li>") { |li| "#{li}\n" }
    end

    # Adds line feeds after the paragraph and list item closing tags.
    #
    # Returns a String.
    def add_line_feeds(text)
      add_line_feeds_to_paragraphs(add_line_feeds_to_list_items(text))
    end

    def content_handle_locale(body, all_locales, extras, links, strip_tags)
      handle_locales(body, all_locales) do |content|
        content = strip_tags(sanitize_text(content)) if strip_tags

        renderer = Decidim::ContentRenderersLinkRenderer.new(content)
        content = renderer.render(links:, extras:).html_safe

        content = Decidim::ContentRenderers::LinkRenderer.new(content).render if links
        content
      end
    end

    # This method is currently being used only for Proposal and Meeting,
    # It aims to load the presenter class, and perform some basic sanitization on the content
    # This method should be used along side simple_format.
    # @param resource [Object] Resource object
    # @param method [Symbol] Method name
    #
    # @return ActiveSupport::SafeBuffer
    def render_sanitized_content(resource, method, presenter_class: nil)
      content = present(resource, presenter_class:).send(method, links: true, strip_tags: !try(:safe_content?))

      return decidim_sanitize(content, {}) unless try(:safe_content?)
      return decidim_sanitize_editor_admin(content, {}) if try(:safe_content_admin?)

      decidim_sanitize_editor(content)
    end
  end
end

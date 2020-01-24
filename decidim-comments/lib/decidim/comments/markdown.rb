# frozen_string_literal: true

require "redcarpet"

module Decidim
  module Comments
    # This class parses a string from plain text (markdown) and
    # renders it as HTML.
    class Markdown < ::Redcarpet::Render::Base
      delegate :render, to: :markdown

      private

      def markdown
        @markdown ||= ::Redcarpet::Markdown.new(renderer)
      end

      def renderer
        @renderer ||= Decidim::Comments::MarkdownRender.new
      end
    end

    # Custom markdown renderer for Comments
    class MarkdownRender < ::Redcarpet::Render::Safe
      def initialize(extensions = {})
        super({
          autolink: true,
          escape_html: false,
          filter_html: true,
          hard_wrap: true,
          lax_spacing: false,
          no_images: true,
          no_styles: true
        }.merge(extensions))
      end

      # renders quotes with a custom css class
      def block_quote(quote)
        %(<blockquote class="comment__quote">#{quote}</blockquote>)
      end

      # removes header tags in comments
      def header(title, _level)
        title
      end

      # prevents empty <p/> in comments
      def paragraph(text)
        return if text.blank?

        "<p>#{text}</p>"
      end
    end
  end
end

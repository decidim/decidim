# frozen_string_literal: true

require "redcarpet"

module Decidim
  module Api
    # Custom helpers, scoped to the api engine.
    #
    module ApplicationHelper
      def render_doc(file)
        md_render File.read(File.join(File.dirname(__FILE__), "../../../../docs", "#{file}.md"))
      end

      def md_render(text)
        text = Redcarpet::Markdown.new(markdown, autolink: true, tables: true, fenced_code_blocks: true).render(text)
        text.html_safe
      end

      def markdown
        @markdown ||= Redcarpet::Render::HTML.new
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  class IframeDisabler
    include Decidim::SanitizeHelper

    def initialize(text, options = {})
      @options = {
        max_length: options[:max_length] || 30,
        tail: options[:tail] || "...",
        count_tags: options[:count_tags] || false,
        count_tail: options[:count_tail] || false,
        tail_before_final_tag: options[:tail_before_final_tag] || false
      }
      @text = text
    end

    def perform
      @document = Nokogiri::HTML::DocumentFragment.parse(@text)
      disable_iframes(@document)
      document.to_html
    end

    private

    attr_reader :document

    def disable_iframes(node)
      if node.name == "iframe"
        node.name = "div"
        node.attributes["class"].value = "disabled-iframe #{node.attributes["class"].value}"
      end

      node.children.each do |child|
        disable_iframes(child)
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  class IframeDisabler
    def initialize(text, _options = {})
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
        old_classes = node.attributes["class"].value
        node.attributes["class"].value = old_classes.present? ? "#{old_classes} disabled-iframe" : "disabled-iframe"
      end

      node.children.each do |child|
        disable_iframes(child)
      end
    end
  end
end

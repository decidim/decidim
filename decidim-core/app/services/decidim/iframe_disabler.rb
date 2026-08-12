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
        # Default title for accessibility
        node["title"] = I18n.t("decidim.shared.embed.title") if node["title"].blank?
        # Disable scrollbar for some embed services
        node["scrolling"] = "no"
        normalize_src(node)
        orig_node = node.to_s
        node.replace(%(<div class="disabled-iframe"><!-- #{orig_node} --></div>))
      end

      node.children.each do |child|
        disable_iframes(child)
      end
    end

    def normalize_src(node)
      src = node["src"]
      return if src.blank?

      # Extracts the embedded URL from iframe src attribute
      embedded = src.match(/src\s*=\s*["']([^"']+)["']/i)&.captures&.first
      src = embedded if embedded

      node["src"] = src.sub(%r{\Ahttps?://(?:www\.|music\.)?youtube\.com/embed/}, "https://www.youtube-nocookie.com/embed/")
    end
  end
end

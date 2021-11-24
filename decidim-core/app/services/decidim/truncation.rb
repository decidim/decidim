# frozen_string_literal: true

module Decidim
  class Truncation
    # Truncates text and html content
    # text - Content to be truncated
    # options - Hash with the options
    #         max_length: An Integer maximum number of characters
    #         tail: A string suffix to be added after truncation
    #         count_tags: A boolean if html is calculate to max length, otherwise just content
    #         count_tail: A boolean value that determines whether max_length contains the tail
    #         tail_before_final_tag: A boolean, show tail inside of tag where text is cutted or before final closing tag.
    def initialize(text, options = {})
      @options = {
        max_length: options[:max_length] || 30,
        tail: options[:tail] || "...",
        count_tags: options[:count_tags] || false,
        count_tail: options[:count_tail] || false,
        tail_before_final_tag: options[:tail_before_final_tag] || false
      }
      @document = Nokogiri::HTML::DocumentFragment.parse(text)
      @tail_added = false
      @remaining = initial_remaining
    end

    # Truncate text or html content added in constructor
    # Returns truncated html
    def truncate
      cut_children(document, options[:count_tags])
      change_quotes(document)
      add_tail(document) if @remaining.negative? && !@tail_added

      # Nokogiri's to_html escapes &quot; to &amp;quot; and we do not want extra &amp so we have to unescape.
      CGI.unescape_html document.to_html
    end

    private

    attr_accessor :tail_added
    attr_reader :document, :options

    def cut_children(node, count_html)
      return @remaining -= node_length(node) if @remaining >= node_length(node)
      return node.unlink if @remaining.negative?
      return cut_with_tags(node) if count_html && @remaining < node_length(node)

      if node.children.empty?
        if @remaining <= node_length(node)
          node.content = cut_content(node)
          @remaining = -1
        end

        return
      end

      node.children.each do |child|
        cut_children(child, count_html)
      end
    end

    def cut_with_tags(node)
      @remaining -= node.to_html.length - node.content.length - closing_tag_length(node)
      cut_children(node, false)
    end

    def change_quotes(node)
      node.content = node.content.gsub("\"", "&quot\;") if node.is_a? Nokogiri::XML::Text
      return if node.children.empty?

      node.children.each do |child|
        change_quotes(child)
      end
    end

    def add_tail(document)
      return if document.children.empty?

      document.add_child(Nokogiri::XML::Text.new(options[:tail], document)) if document.children[-1].is_a? Nokogiri::XML::Text
      document.children[-1].add_child(Nokogiri::XML::Text.new(options[:tail], document))
      @tail_added = true
    end

    def cut_content(node)
      tail = options[:tail_before_final_tag] ? "" : options[:tail]
      @tail_added = true if tail.present?

      "#{node.content.truncate(@remaining, omission: "")}#{tail}"
    end

    def initial_remaining
      return options[:max_length] unless options[:count_tail]

      options[:max_length] - options[:tail].length
    end

    def closing_tag_length(node)
      node.to_html.slice(node.to_html.index(node.content)..-1).sub(node.content, "").length
    end

    def node_length(node)
      options[:count_tags] ? node.to_html.length : node.content.length
    end
  end
end

# frozen_string_literal: true

module Decidim
  class HtmlTruncation
    include Decidim::SanitizeHelper

    # Truncates html content
    # text - Content to be truncated
    # options - Hash with the options
    #         max_length: An Integer maximum number of characters
    #         tail: Suffix to add after truncation
    #         count_tags: A boolean which tells if html tags should be calculated to max length, otherwise just content
    #         count_tail: A boolean value that determines whether max_length contains the tail
    #         tail_before_final_tag: A boolean, add tail before final tag if true, otherwise add tail where content is cut.
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

    # Perform truncation to the html content (text) added in constructor
    # Returns truncated String
    def perform
      @document = Nokogiri::HTML::DocumentFragment.parse(@text)
      @tail_added = false
      @remaining = initial_remaining
      @cut = false
      cut_children(document, options[:count_tags])
      add_tail(document) if @remaining.negative? && !@tail_added
      escape_html_from_content(document)

      # Nokogiri's to_html escapes &quot; to &amp;quot; and we do not want extra &amp so we have to unescape.
      CGI.unescape_html(document.to_html).gsub("\n", "")
    end

    private

    attr_reader :document, :options

    def cut_children(node, count_html)
      return @remaining -= node_length(node, count_html) if @remaining >= node_length(node, count_html)
      return node.unlink if @remaining.negative?
      return cut_with_tags(node, true) if count_html && @remaining < node_length(node, count_html)

      if node.children.empty?
        if node.content.present? && @remaining < node_length(node, count_html)
          cut_content(node)
          @remaining = -1
        else
          @remaining -= node_length(node, count_html)
        end

        return
      end

      node.children.each do |child|
        cut_children(child, count_html)
      end
    end

    def escape_html_from_content(node)
      node.content = decidim_html_escape(node.content) if node.is_a? Nokogiri::XML::Text
      return if node.children.empty?

      node.children.each do |child|
        escape_html_from_content(child)
      end
    end

    def cut_with_tags(node, parent)
      if parent
        return node.children.each { |child| cut_with_tags(child, false) } if node.children.present?

        return ignore_closing_tag_and_cut(node)
      end
      return node.unlink if @cut

      if @remaining < node_length(node, true)
        @cut = true
        return ignore_closing_tag_and_cut(node) if @remaining > opening_tag_length(node) || node.content.present?
      end
      @remaining -= node_length(node, true)
    end

    def ignore_closing_tag_and_cut(node)
      @remaining -= opening_tag_length(node)
      cut_content(node)
      @remaining = -1
    end

    def add_tail(document)
      return if document.children.empty? || @tail_added

      target = document.children[-1]
      if target.is_a?(Nokogiri::XML::Text) || target.content.empty?
        document.add_child(Nokogiri::XML::Text.new(options[:tail], document))
      else
        target.add_child(Nokogiri::XML::Text.new(options[:tail], document))
      end
      @tail_added = true
    end

    def cut_content(node)
      tail = options[:tail_before_final_tag] ? "" : options[:tail]
      @tail_added = true if tail.present?

      node.content = "#{node.content.truncate(@remaining, omission: "")}#{tail}"
    end

    def initial_remaining
      return options[:max_length] unless options[:count_tail]

      options[:max_length] - options[:tail].length
    end

    def opening_tag_length(node)
      closing_tag_index = node.to_html.rindex("</") || node.to_html.length
      node.to_html.length - (node.to_html.length - closing_tag_index) - node.content.length
    end

    def node_length(node, count_html)
      count_html ? node.to_html.length : node.content.length
    end
  end
end

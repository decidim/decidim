# frozen_string_literal: true

module Decidim
  class Truncation
    include ActionView::Context
    include ActionView::Helpers::TagHelper

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
      content_array = []

      document.children.each do |node|
        if node_length(node) > @remaining
          content_array << truncate_last_node(node)
          break
        end

        change_quotes(node)
        content_array << node.to_html
        @remaining -= node_length(node)
      end

      # Nokogiri's to_html escapes &quot; to &amp;quot; and we do not want extra &amp so we have to unescape.
      CGI.unescape_html content_array.join.html_safe
    end

    private

    attr_accessor :tail_added, :remaining
    attr_reader :document, :options

    def change_quotes(node)
      node.content = node.content.gsub("\"", "&quot\;") if node.is_a? Nokogiri::XML::Text
      return if node.children.empty?

      node.children.each do |child|
        change_quotes(child)
      end
    end

    def truncate_last_node(node)
      if node.children.count <= 1
        @remaining = (@remaining - opening_tag_length(node)) if options[:count_tags]
        target = find_target(node) || node
        target.content = cut_content(target)
        return node_to_html(node)
      end

      cut_children(node)
      node_to_html(node)
    end

    def node_to_html(node)
      node.add_child(Nokogiri::XML::Text.new(options[:tail], document)) if add_tail_node?(node)
      change_quotes(node)
      node.to_html
    end

    def cut_content(node)
      tail = add_tail_node?(node) ? "" : options[:tail]
      @tail_added = true if tail.present?

      "#{node.content.truncate(@remaining, omission: "")}#{tail}"
    end

    def cut_children(node)
      cutted = false
      node.children.each do |child|
        if !cutted && node_length(child) > @remaining
          child.content = cut_content(child)
          cutted = true
        elsif cutted
          child.unlink
        end
        @remaining -= node_length(child)
      end
    end

    def find_target(node)
      return node if node.children.empty?

      node.children.each do |child|
        if node_length(child) > @remaining
          return child if child.children.count <= 1

          return find_target(child)
        end

        @remaining -= node_length(child)
      end

      node.children.first
    end

    def initial_remaining
      return options[:max_length] unless options[:count_tail]

      options[:max_length] - options[:tail].length
    end

    def opening_tag_length(node)
      node.to_html.length - node.content.length - (node.name.length + 3) # 3 = </>
    end

    def node_length(node)
      options[:count_tags] ? node.to_html.length : node.content.length
    end

    def add_tail_node?(node)
      return false if @tail_added

      options[:tail_before_final_tag] && node.children.present?
    end
  end
end

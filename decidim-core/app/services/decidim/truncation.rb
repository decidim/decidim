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
    end

    def truncate
      content_array = []
      remaining = initial_remaining

      document.children.each do |node|
        if node_length(node) > remaining
          content_array << truncate_last_node(node, remaining)
          break
        end

        content_array << node.to_html
        remaining -= node_length(node)
      end

      content_array.join.html_safe
    end

    private

    attr_accessor :tail_added
    attr_reader :document, :options

    def truncate_last_node(node, remaining)
      if node.children.count <= 1
        remaining = options[:count_tags] ? (remaining - opening_tag_length(node)) : remaining
        target = node.children.count == 1 ? node.children.first : node
        target.content = cut_off(target, remaining)
      else
        node.children.each do |child|
          if node_length(child) > remaining
            child.content = cut_off(child, remaining)
            break
          end
          remaining -= node_length(child)
        end
      end

      node.add_child(Nokogiri::XML::Text.new(options[:tail], document)) if add_tail_node?(node) && !@tail_added
      node.to_html
    end

    def cut_off(node, remaining)
      tail = add_tail_node?(node) ? "" : options[:tail]
      @tail_added = true if tail.present?

      "#{node.content.truncate(remaining, omission: "")}#{tail}"
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
      options[:tail_before_final_tag] && node.children.present?
    end
  end
end

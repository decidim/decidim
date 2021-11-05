# frozen_string_literal: true

module Decidim
  class Truncation
    include ActionView::Context
    include ActionView::Helpers::TagHelper

    def initialize(text, options = {})
      @options = {
        max_length: options[:max_length] || 30,
        tail: options[:tail] || "...",
        count_tags: options[:count_tags] || false,
        count_tail: options[:count_tail] || false,
        tail_before_final_tag: options[:tail_before_final_tag] || false
      }
      @document = Nokogiri::HTML::DocumentFragment.parse(text)
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

      content_tag(:p) do
        content_array.join.html_safe
      end
    end

    private

    attr_reader :document, :options

    def truncate_last_node(node, remaining)
      if node.children.count <= 1
        remaining = options[:count_tags] ? (remaining - opening_tag_length(node)) : remaining
        node.content = truncate_and_add_tail(node, remaining)
        return node.to_html
      end

      node.children.each do |child|
        if node_length(child) > remaining
          child.content = truncate_and_add_tail(child, remaining)
          break
        end
        remaining -= node_length(child)
      end

      node.to_html
    end

    def truncate_and_add_tail(node, remaining)
      "#{node.content.truncate(remaining, omission: "")}#{options[:tail]}"
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
  end
end

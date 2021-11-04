# frozen_string_literal: true

module Decidim
  class Truncation
    include ActionView::Context
    include ActionView::Helpers::TagHelper

    def truncate(text, options = {})
      @node_array = []
      fill_node_array(Nokogiri::HTML::DocumentFragment.parse(text))
      remaining = initial_remaining(options)

      final = ""
      @node_array.each do |tag|
        if tag.content.length <= remaining
          final += tag.to_html
          remaining -= tag.content.length
        else
          # tag.content.truncate(remaining, omission: options[:tail])
          final += last_tag(tag, remaining)
          break
        end
      end

      content_tag(:p) do
        final.html_safe
      end
    end

    private

    # rubocop:disable all
    #asd
    def last_tag(tag, remaining, options)
      foo = ""
      tag.children.each do |child|
        if child.content.length < remaining
          foo += child.to_html
          remaining -= child.content.length
        else
          child.content = truncate(child.content, omission: options[:tail])
        end
      end
    end
    # rubocop:enable all

    def add_tag(content, tag)
      content_tag(tag.to_sym) do
        content
      end
    end

    def initial_remaining(options)
      return options[:max_length] unless options[:count_tail]

      options[:max_length] - options[:tail].length
    end

    def fill_node_array(node)
      node.children.each do |child|
        @node_array << child
      end
    end
  end
end

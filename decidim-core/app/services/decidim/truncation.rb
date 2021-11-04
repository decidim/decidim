# frozen_string_literal: true

module Decidim
  class Truncation
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
          final += tag.content.truncate(remaining, omission: options[:tail])
        end
      end

      final
    end

    private

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

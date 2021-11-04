# frozen_string_literal: true

module Decidim
  class Truncation
    include ActionView::Context
    include ActionView::Helpers::TagHelper

    def truncate(text, options = {})
      doc = Nokogiri::HTML::DocumentFragment.parse(text)
      remaining = initial_remaining(options)
      content_array = []

      doc.children.each do |tag|
        if tag.content.length <= remaining
          content_array << tag.to_html
          remaining -= tag.content.length
        else
          # tag.content.truncate(remaining, omission: options[:tail])
          content_array << last_tag(tag, remaining, options)
          break
        end
      end

      content_tag(:p) do
        content_array.join.html_safe
      end
    end

    private

    def last_tag(tag, remaining, options)
      if tag.children.empty?
        tag.content = tag.content.truncate(remaining + options[:tail].length, omission: options[:tail])
        return tag.to_html
      end

      array = []
      tag.children.each do |child|
        if child.content.length <= remaining
          array << child.to_html
        elsif remaining.zero?
          array << options[:tail]
          break
        else
          child.content = child.content.truncate(remaining + options[:tail].length, omission: options[:tail])
          array << child.to_html
          break
        end
      end

      content_tag(tag.name.to_sym) do
        array.join.html_safe
      end
    end

    def add_tag(content, tag)
      content_tag(tag.to_sym) do
        content
      end
    end

    def initial_remaining(options)
      return options[:max_length] unless options[:count_tail]

      options[:max_length] - options[:tail].length
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Design
    module ApplicationHelper
      def section_title(section)
        content_tag(:h2, section_text(section), class: "design__heading__3xl")
      end

      def section_text(section)
        section[:title] || section[:id].titleize
      end

      def render_content(content)
        case content[:type]
        when :text
          html = ""
          content[:values].each do |value|
            html += content_tag(:p, value, class: content[:class])
          end
          html.html_safe
        when :partial
          render partial: content[:template], locals: content[:locals]
        else
          content[:values].to_s.html_safe
        end
      end

      def render_row(row)
        if row.is_a?(Array)
          html = ""
          row.each do |cell|
            html += render_cell(cell)
          end
          html.html_safe
        end
      end

      def render_cell(cell)
        content_tag(:td) do
          if cell.is_a?(Hash)
            send(cell[:method], *cell[:args]).to_s
          else
            cell
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Design
    module ApplicationHelper
      # For the moment keep this as a constant and later decide where to move
      # this
      RELEASE_ID = "develop"

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

      def render_cell_snippet(content)
        return "" if content[:cell_snippet].blank?

        render partial: "decidim/design/shared/cell_snippet", locals: cell_snippet_locals(content[:cell_snippet][:cell], content[:cell_snippet][:args])
      end

      def cell_snippet_locals(cell, args)
        path = args.delete(:path) || File.join("decidim-core/app/cells/", cell)
        {
          text: path,
          url: "https://github.com/decidim/decidim/blob/#{RELEASE_ID}/#{path}_cell.rb",
          cell:,
          args:
        }
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

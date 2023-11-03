# frozen_string_literal: true

module Decidim
  module Design
    module ApplicationHelper
      # For the moment keep this as a constant and later decide where to move
      # this
      RELEASE_ID = "develop"

      def section_title(section)
        content_tag(:h2, section_text(section))
      end

      def section_subtitle(section)
        content_tag(:h3, section_text(section))
      end

      def section_text(section)
        title = section[:title] || section[:id]&.titleize
        return title unless section[:label].present?

        title += content_tag(:span, section[:label], class: "label")
        title.html_safe
      end

      def render_content(content)
        case content[:type]
        when :text
          html = ""
          content[:values].each do |value|
            html += content_tag(:p, value.html_safe, class: content[:class])
          end
          html.html_safe
        when :table
          render partial: "decidim/design/shared/table", locals: content.slice(:items).merge(content[:options] || {})
        when :partial
          partial = render_partial(content)

          return partial unless content[:layout].present?

          render layout: content[:layout] do
            partial.html_safe
          end
        else
          content[:values].to_s.html_safe
        end
      end

      def render_partial(content)
        if content[:template].is_a?(Array)
          templates = ""
          content[:template].each do |value|
            templates += render partial: value, locals: content[:locals]
          end
          return templates
        end

        render partial: content[:template], locals: content[:locals]
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

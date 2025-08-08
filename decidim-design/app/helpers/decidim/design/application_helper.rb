# frozen_string_literal: true

module Decidim
  module Design
    module ApplicationHelper
      include Decidim::ApplicationHelper
      include Decidim::IconHelper

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
        return title if section[:label].blank?

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
        when :cell_table
          render partial: "decidim/design/shared/cell_table", locals: content.slice(:cell_snippet).merge(content[:options] || {})
        when :table
          render partial: "decidim/design/shared/table", locals: content.slice(:items).merge(content[:options] || {})
        when :partial
          partial = render_partial(content)

          return partial if content[:layout].blank?

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

        render partial: "decidim/design/shared/cell_snippet", locals: cell_snippet_locals(content[:cell_snippet])
      end

      def render_cell_call_textarea(cell_data)
        render partial: "decidim/design/shared/cell_call_textarea", locals: cell_snippet_locals(cell_data)
      end

      def cell_snippet_locals(args)
        path = args.delete(:path) || File.join("decidim-core/app/cells/", args[:cell])
        url = "https://github.com/decidim/decidim/blob/#{RELEASE_ID}/#{path}_cell.rb"
        call_string = args.delete(:call_string) || ""
        args_texts = call_string.present? ? [] : inspect_args(args[:args])

        args.merge(text: path, url:, call_string:, args_texts:)
      end

      def inspect_args(args = [])
        return ["nil"] if args.blank?

        args.map do |arg|
          next arg.inspect if arg.is_a?(String)
          next arg.except(:context).inspect if arg.is_a?(Hash)

          class_name = arg.class.name
          next "#{class_name}.take" if arg.is_a?(Decidim::ApplicationRecord)

          class_name
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

# frozen_string_literal: true

require "hexapdf"

module Decidim
  module Budgets
    class OrderPDF
      include Decidim::TranslatableAttributes
      include Decidim::ResourceHelper

      delegate :document, to: :composer

      attr_reader :order

      def initialize(order)
        @order = order
      end

      def render
        composer.styles(**styles)

        add_content

        ::Decidim::Exporters::ExportData.new(composer.write_to_string, "pdf")
      end

      def composer
        @composer ||= ::HexaPDF::Composer.new(page_orientation: :portrait, page_size: :A4)
      end

      def styles
        {
          h1: { font: bold_font, text_align: :left, font_size: 15 },
          text: { font:, text_align: :left, font_size: 10 }
        }
      end

      def add_content
        composer.text(I18n.t("decidim.budgets.order_pdf.title"), style: :h1, position: [30, 700])
        composer.text(I18n.t("decidim.budgets.order_pdf.text", space_name:), style: :text, position: [30, 670])
        order.projects.each_with_index do |project, index|
          composer.text("- #{translated_attribute(project.title)}", style: :text, position: [30, 650 - (index * 20)])
        end

        composer.text(component_url, style: :text, position: [30, 650 - (order.projects.count * 20) - 10])
      end

      def space_name
        translated_attribute(budget.participatory_space.title)
      end

      def component_url
        Decidim::ResourceLocatorPresenter.new(budget).url
      end

      def budget
        @budget ||= order.budget
      end

      def font
        @font ||= load_font("source-sans-pro-v21-cyrillic_cyrillic-ext_greek_greek-ext_latin_latin-ext_vietnamese-regular.ttf")
      end

      def bold_font
        @bold_font ||= load_font("source-sans-pro-v21-cyrillic_cyrillic-ext_greek_greek-ext_latin_latin-ext_vietnamese-700.ttf")
      end

      def load_font(path)
        document.fonts.add(Decidim::Core::Engine.root.join("app/packs/fonts/decidim/").join(path))
      end
    end
  end
end

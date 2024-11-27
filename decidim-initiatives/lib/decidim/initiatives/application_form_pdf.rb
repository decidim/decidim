# frozen_string_literal: true

require "hexapdf"

module Decidim
  module Initiatives
    class ApplicationFormPDF
      include Decidim::OrganizationHelper
      def initialize(initiative)
        @initiative = initiative
      end

      def render
        composer.styles(**styles)

        add_logo
        add_organization_data_box
        add_author_box
        add_promoter_box

        composer.new_page

        add_initiative_metadata_box
        add_attachments_box
        add_signature_box
        add_legal_box

        composer.write_to_string
      end

      private

      attr_reader :initiative

      delegate :document, to: :composer
      delegate :layout, to: :document

      def page = document.pages.first

      def page_width = page.box(:media).width

      def page_height = page.box(:media).height

      def styles
        {
          h1: { font: bold_font, text_align: :center, font_size: 16, margin: [10, 0, 10, 0] },
          title: { font: bold_font, text_align: :center, font_size: 12, margin: [10, 0, 10, 0] },
          text: { font: bold_font, text_align: :left, font_size: 12, margin: [0, 0, 10, 0] },
          td: { font:, text_align: :left, font_size: 12, margin: [0, 0, 10, 0] }
        }
      end

      def add_author_box
        cells = [
          [{ content: layout.text(I18n.t("author_title", scope: "decidim.initiatives.initiatives.print"), style: :title), col_span: 3 }],
          [{ content: layout.text(I18n.t("id_number", scope: "decidim.initiatives.initiatives.print"), style: :td), col_span: 3, padding: [5, 5, 20, 5] }],
          [{ content: layout.text(I18n.t("full_name", scope: "decidim.initiatives.initiatives.print"), style: :td), col_span: 3, padding: [5, 5, 20, 5] }],
          [{ content: layout.text(I18n.t("address", scope: "decidim.initiatives.initiatives.print"), style: :td), col_span: 3, padding: [5, 5, 20, 5] }],
          [
            { content: layout.text(I18n.t("city", scope: "decidim.initiatives.initiatives.print"), style: :td), padding: [5, 5, 20, 5] },
            { content: layout.text(I18n.t("province", scope: "decidim.initiatives.initiatives.print"), style: :td), padding: [5, 5, 20, 5] },
            { content: layout.text(I18n.t("postal_code", scope: "decidim.initiatives.initiatives.print"), style: :td), padding: [5, 5, 20, 5] }
          ],
          [
            { content: layout.text(I18n.t("phone_number", scope: "decidim.initiatives.initiatives.print"), style: :td), padding: [5, 5, 20, 5] },
            { content: layout.text(I18n.t("email", scope: "decidim.initiatives.initiatives.print"), style: :td), col_span: 2, padding: [5, 5, 20, 5] }
          ]
        ]
        composer.table(cells, cell_style: { border: { width: 1 } }, style: { margin: [10, 0] })
      end

      def add_signature_box
        cells = [
          layout.text(I18n.t("place_date", scope: "decidim.initiatives.initiatives.print"), style: :title),
          layout.text(I18n.t("signature", scope: "decidim.initiatives.initiatives.print"), style: :title)
        ]
        composer.table([cells], cell_style: { border: { width: 0 } }, style: { margin: [10, 0] })
      end

      def add_attachments_box
        cells = [
          [{ content: layout.text(I18n.t("initiative.attachments", scope: "decidim.initiatives.initiatives.print"), style: :title), col_span: 10 }]
        ]

        6.times do
          cols = [
            { content: layout.text(""), padding: 15 },
            { content: layout.text(""), padding: 15, col_span: 9 }
          ]
          cells.push(cols)
        end

        composer.table(cells, cell_style: { border: { width: 1 } }, style: { margin: [10, 0] })
      end

      def add_promoter_box
        cells = [
          [{ content: layout.text(I18n.t("members_header", scope: "decidim.initiatives.initiatives.print"), style: :title), col_span: 3 }],
          [
            { content: layout.text(I18n.t("full_name", scope: "decidim.initiatives.initiatives.print"), style: :td), padding: [5, 5, 20, 5] },
            { content: layout.text(I18n.t("id_number", scope: "decidim.initiatives.initiatives.print"), style: :td), padding: [5, 5, 20, 5] },
            { content: layout.text(I18n.t("address", scope: "decidim.initiatives.initiatives.print"), style: :td), padding: [5, 5, 20, 5] }
          ]
        ]

        4.times do
          cols = []
          3.times do
            cols.push({ content: layout.text(""), padding: 15 })
          end
          cells.push(cols)
        end

        composer.table(cells, cell_style: { border: { width: 1 } }, style: { margin: [10, 0] })
      end

      def add_legal_box
        composer.text(I18n.t("legal_text", scope: "decidim.initiatives.initiatives.print"), style: {
                        font:, font_size: 10, margin: [100, 0]
                      })
      end

      def add_initiative_metadata_box
        composer.text(I18n.t("initiative.type", scope: "decidim.initiatives.initiatives.print"), style: :text)
        composer.text(translated_attribute(initiative.type.title), style: :td)
        composer.text(I18n.t("initiative.title", scope: "decidim.initiatives.initiatives.print"), style: :text)
        composer.text(translated_attribute(initiative.title), style: :td)
        composer.text(I18n.t("initiative.description", scope: "decidim.initiatives.initiatives.print"), style: :text)
        composer.text(translated_attribute(initiative.description), style: :td)
      end

      def add_organization_data_box
        composer.text(organization_name(initiative.organization), style: :h1)
        cells = [
          layout.text(I18n.t("general_title", scope: "decidim.initiatives.initiatives.print"), style: :title)
        ]
        composer.table([cells], cell_style: { border: { width: 1 } })
      end

      def add_logo
        return if initiative.organization.logo.blank?

        attached_image = initiative.organization.attached_uploader(:logo).variant(:thumb)
        logo = document.images.add(StringIO.new(attached_image.download))
        height, width = compute_dimensions(attached_image, 160, 80)

        cells = ["", layout.image(logo, width:, height:), ""]
        composer.table([cells], cell_style: { border: { width: 0 } })
      end

      def compute_dimensions(attached_image, max_width, max_height)
        metadata = attached_image.blob.metadata.with_indifferent_access
        aspect_ratio = metadata[:width] / metadata[:height]

        if metadata[:width] >= metadata[:height]
          max_height = (max_height / aspect_ratio).round
        else
          max_width = (max_width / aspect_ratio).round
        end

        return max_height, max_width
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

      def composer
        @composer ||= ::HexaPDF::Composer.new
      end
    end
  end
end

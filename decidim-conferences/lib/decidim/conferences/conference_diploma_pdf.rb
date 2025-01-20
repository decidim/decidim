# frozen_string_literal: true

require "hexapdf"
require "open-uri"

module Decidim
  module Conferences
    class ConferenceDiplomaPDF
      include ActionView::Helpers::AssetUrlHelper
      include Shakapacker::Helper
      include Decidim::TranslatableAttributes
      include Decidim::SanitizeHelper

      def initialize(conference, user)
        @conference = conference
        @user = user
      end

      def render
        composer.styles(**styles)

        create_border
        add_logo

        add_text

        add_hr_line
        add_verified_by_text
        add_signature_picture
        add_verified_by_signature

        document.write_to_string
      end

      private

      attr_reader :conference

      delegate :document, to: :composer

      def page_orientation = :landscape

      def page = document.pages.first

      def page_width = page.box(:media).width

      def page_height = page.box(:media).height

      def layout = document.layout

      def box_width = page_width * 0.9

      def box_height = page_height * 0.7

      def styles
        {
          h1: { font: bold_font, text_align: :center, font_size: 18 },
          h2: { font: bold_font, text_align: :center, font_size: 15 },
          text: { font:, text_align: :center, font_size: 10 },
          verified: { font:, text_align: :center, font_size: 8 },
          bold: { font: bold_font, text_align: :center, font_size: 10 }
        }
      end

      def composer
        @composer ||= ::HexaPDF::Composer.new(page_orientation:)
      end

      def add_text
        width = 710

        composer.text(translated_attribute(conference.title), style: :h1, position: [30, box_height - 130], width:)
        composer.text(I18n.t("decidim.conferences.admin.send_conference_diploma_mailer.diploma_user.certificate_of_attendance"),
                      style: :h2, position: [30, box_height - 160], width:)

        text = I18n.t("decidim.conferences.admin.send_conference_diploma_mailer.diploma_user.certificate_of_attendance_description",
                      user: @user.name,
                      title: translated_attribute(@conference.title),
                      location: @conference.location,
                      start: I18n.l(@conference.start_date, format: :decidim_short),
                      end: I18n.l(@conference.end_date, format: :decidim_short))

        texts_to_bold = [
          @user.name,
          translated_attribute(@conference.title),
          I18n.l(@conference.start_date, format: :decidim_short),
          I18n.l(@conference.end_date, format: :decidim_short)
        ]

        texts_to_bold = texts_to_bold.map { |bold| decidim_sanitize(bold, strip_tags: true) }

        text = decidim_sanitize(text, strip_tags: true)
        text_fragments = create_text_fragments(text, texts_to_bold)

        result = HexaPDF::Layout::TextLayouter.new.fit(text_fragments, 710, 30)

        x_width = (page_width - result.lines.first.width) / 2

        result.draw(composer.canvas, x_width, 260)
      end

      # Function to create text fragments with bold parts
      def create_text_fragments(text, texts_to_bold)
        fragments = []
        current_position = 0

        texts_to_bold.sort_by! { |bold_text| text.index(bold_text) }

        texts_to_bold.each do |bold_text|
          bold_position = text.index(bold_text, current_position)

          if bold_position > current_position
            part = text[current_position...bold_position]
            fragments << HexaPDF::Layout::TextFragment.create(part, styles[:text])
          end

          fragments << HexaPDF::Layout::TextFragment.create(bold_text, styles[:bold])

          current_position = bold_position + bold_text.length
        end

        if current_position < text.length
          part = text[current_position..-1]
          fragments << HexaPDF::Layout::TextFragment.create(part, font: styles[:text])
        end

        fragments
      end

      def compute_dimensions(attached_image, max_width, max_height)
        # Retrieve the image metadata
        metadata = attached_image.blob.metadata

        # If metadata does not contain width and height, return the max dimensions
        return max_height, max_width unless metadata.has_key?(:width) && metadata.has_key?(:height)

        # Calculate the aspect ratio of the image
        aspect_ratio = metadata[:width].to_f / metadata[:height]

        # Adjust the width based on the max height while preserving the aspect ratio
        adjusted_width = (max_height * aspect_ratio).round

        # Return the max height and the adjusted width
        return max_height, adjusted_width
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

      def add_verified_by_text
        composer.text(I18n.t("decidim.conferences.admin.send_conference_diploma_mailer.diploma_user.attendance_verified_by"),
                      style: :bold, position: [30, 160], width: 710)
      end

      def add_signature_picture
        attached_image = conference.attached_uploader(:signature).variant(:original)
        logo = document.images.add(StringIO.new(attached_image.download))
        max_height, max_width = compute_dimensions(attached_image, 80, 40)

        box_x = (page_width - max_width) / 2
        box_y = 150
        frame = ::HexaPDF::Layout::Frame.new(box_x, box_y, 80, 40)

        box = document.layout.box do |canvas, _box|
          canvas.image(logo, at: [0, 0], width: max_width, height: max_height)
        end

        result = frame.fit(box)
        frame.draw(page.canvas, result)
      end

      def add_hr_line
        frame = ::HexaPDF::Layout::Frame.new(66, 210, 710, 10)

        box = document.layout.box do |canvas, _box|
          canvas.line_width = 0.5
          canvas.stroke_color(0, 0, 0)
          canvas.line(0, 10, 710, 10).stroke
        end
        result = frame.fit(box)
        frame.draw(page.canvas, result)
      end

      def add_verified_by_signature
        composer.text([
          I18n.l(conference.sign_date, format: :decidim_short),
          conference.signature_name
        ].join(", "), style: :verified, position: [30, 95], width: 710)
      end

      def add_logo
        attached_image = conference.attached_uploader(:main_logo).variant(:original)
        logo = document.images.add(StringIO.new(attached_image.download))
        max_height, max_width = compute_dimensions(attached_image, 160, 80)

        box_x = (page_width - max_width) / 2
        box_y = page_height - 220
        frame = ::HexaPDF::Layout::Frame.new(box_x, box_y, 160, 80)

        box = document.layout.box do |canvas, _box|
          canvas.image(logo, at: [0, 0], width: max_width, height: max_height)
        end

        result = frame.fit(box)
        frame.draw(page.canvas, result)
      end

      def create_border
        background_image = StringIO.new(Rails.root.join("public/#{image_pack_path("media/images/pattern.png")}").read)

        box_x = (page_width - box_width) / 2
        box_y = (page_height - box_height) / 2

        frame = ::HexaPDF::Layout::Frame.new(box_x, box_y, box_width, box_height)

        box = document.layout.image_box(background_image, width: box_width, height: box_height)
        result = frame.fit(box)
        frame.draw(page.canvas, result)

        frame = ::HexaPDF::Layout::Frame.new(box_x, box_y, box_width, box_height)

        box = document.layout.box do |canvas, _box|
          canvas.fill_color("FFFFFF")
          canvas.rectangle(10, 10, box_width - 20, box_height - 20)
          canvas.fill
        end

        result = frame.fit(box)
        frame.draw(page.canvas, result)
      end
    end
  end
end

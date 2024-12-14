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
        add_signature

        add_text

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

      def box_x = (page_width - box_width) / 2

      def box_y = (page_height - box_height) / 2

      def styles
        {
          h1: { font: bold_font, text_align: :center, font_size: 18, margin: [0, 0, 10, 0] },
          h2: { font: bold_font, text_align: :center, font_size: 15, margin: [0, 0, 10, 0] },
          text: { font:, text_align: :center, font_size: 12, margin: [0, 0, 10, 0] },
          bold: { font: bold_font, text_align: :center, font_size: 12, margin: [0, 0, 10, 0] }
        }
      end

      def composer
        @composer ||= ::HexaPDF::Composer.new(page_orientation:)
      end

      def create_border
        background_image = StringIO.new(Rails.root.join("public/#{image_pack_path("media/images/pattern.png")}").read)

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

      def add_text
        composer.text(translated_attribute(conference.title), style: :h1, position: [0, box_height - 130])
        composer.text(I18n.t("decidim.conferences.admin.send_conference_diploma_mailer.diploma_user.certificate_of_attendance"),
                      style: :h2, position: [0, box_height - 170])

        text = I18n.t("decidim.conferences.admin.send_conference_diploma_mailer.diploma_user.certificate_of_attendance_description",
                      user: @user.name,
                      title: translated_attribute(@conference.title),
                      location: @conference.location,
                      start: I18n.l(@conference.start_date, format: :decidim_short),
                      end: I18n.l(@conference.end_date, format: :decidim_short))

        composer.formatted_text([decidim_sanitize(text, strip_tags: true)], style: :text, width: box_width - 50, position: [10, box_height - 200])
      end

      def add_logo
        attached_image = conference.attached_uploader(:main_logo).variant(:original)
        logo = document.images.add(StringIO.new(attached_image.download))

        frame = ::HexaPDF::Layout::Frame.new(box_x, box_y, box_width, box_height)

        max_height, max_width = compute_dimensions(attached_image, 160, 120)

        box_x = (frame.width - max_width) / 2
        box_y = frame.height - ((frame.height - max_height) / 2) + 30

        box = document.layout.box do |canvas, _box|
          canvas.image(logo, at: [box_x, box_y], width: max_width, height: max_height)
        end

        result = frame.fit(box)
        frame.draw(page.canvas, result)
      end

      def compute_dimensions(attached_image, max_width, max_height)
        metadata = attached_image.blob.metadata
        aspect_ratio = metadata[:width] / metadata[:height]

        if metadata[:width] >= metadata[:height]
          max_height = (max_width / aspect_ratio).round
        else
          max_width = (max_height / aspect_ratio).round
        end

        return max_height, max_width
      end

      # @private
      # Create a frame in the bottom part of the document that has 150px
      # Attach a signature image to which we compute the aspect ratio, so that the image is not getting blurred or skewed
      # Place 2 texts around the signature, at the nearest possible places, and we do a lot of calculations to counter the mix of geometries
      def add_signature
        attached_image = conference.attached_uploader(:signature).variant(:original)
        logo = document.images.add(StringIO.new(attached_image.download))

        max_height, max_width = compute_dimensions(attached_image, 80, 60)
        frame = ::HexaPDF::Layout::Frame.new(box_x, box_y, box_width, max_height)

        box_x = (frame.width - max_width) / 2

        composer.text(I18n.t("decidim.conferences.admin.send_conference_diploma_mailer.diploma_user.attendance_verified_by"),
                      style: :bold, position: [0, frame.height + max_height + 20])

        composer.text([
          I18n.l(conference.sign_date, format: :decidim_short),
          conference.signature_name
        ].join(", "), style: :text, position: [0, frame.height + max_height])

        composer.image(logo, position: [box_x, frame.height], width: max_width, height: max_height)
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

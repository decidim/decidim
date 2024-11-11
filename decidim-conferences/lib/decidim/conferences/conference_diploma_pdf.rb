# frozen_string_literal: true

require "hexapdf"
require "open-uri"

module Decidim
  module Conferences
    class ConferenceDiplomaPDF
      include ActionView::Helpers::AssetUrlHelper
      include Shakapacker::Helper

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
      def font_family = "Times"

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
          h1: { font: composer.document.fonts.add(font_family, variant: :bold), text_align: :center, font_size: 18, margin: [0, 0, 10, 0] },
          h2: { font: composer.document.fonts.add(font_family, variant: :bold), text_align: :center, font_size: 15, margin: [0, 0, 10, 0] },
          text: { font: composer.document.fonts.add(font_family), text_align: :center, font_size: 12, margin: [0, 0, 10, 0] },
          bold: { font: composer.document.fonts.add(font_family, variant: :bold), text_align: :center, font_size: 12, margin: [0, 0, 10, 0] }
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
        composer.text("Dolor rerum veniam in possimus.", style: :h1, position: [0, box_height - 130])
        composer.text("Certificate of Attendance", style: :h2, position: [0, box_height - 170])
        composer.formatted_text([
                                  "This is to certify that ",
                                  { text: "Gary Herzog", style: :bold },
                                  " has attended and taken part in the ",

                                  { text: "Dolor rerum veniam in possimus.", style: :bold },
                                  " held at the on ",
                                  { text: "01/11/2024 - 03/01/2025", style: :bold }
                                ], style: :text, position: [0, box_height - 200])
      end

      def add_logo
        attached_image = conference.attached_uploader(:main_logo).variant(:thumb)
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
          max_width = 160
          max_height = (max_width / aspect_ratio).round
        else
          max_height = 120
          max_width = (max_height / aspect_ratio).round
        end

        return max_height, max_width
      end

      # @private
      # Create a frame in the bottom part of the document that has 150px
      # Attach a signature image to which we compute the aspect ratio, so that the image is not getting blurred or skewed
      # Place 2 texts around the signature, at the nearest possible places, and we do a lot of calculations to counter the mix of geometries
      def add_signature
        attached_image = conference.attached_uploader(:signature).variant(:thumb)
        logo = document.images.add(StringIO.new(attached_image.download))

        frame = ::HexaPDF::Layout::Frame.new(box_x, box_y, box_width, 150)

        max_height, max_width = compute_dimensions(attached_image, 80, 60)

        box_x = (frame.width - max_width) / 2

        attendence = composer.text("Attendance verified by", style: :bold, position: [0, frame.height])

        image = composer.image(logo, position: [box_x, frame.height - attendence.height - max_height], width: max_width, height: max_height)

        composer.text("06/11/2024, LUPU AL", style: :text, position: [0, frame.height - attendence.height - (2 * (image.height + max_height))])
      end
    end
  end
end

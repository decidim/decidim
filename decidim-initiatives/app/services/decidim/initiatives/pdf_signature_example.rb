# frozen_string_literal: false

require "origami"
require "tempfile"
require_relative "../../../../lib/gem_overrides/origami/date"

module Decidim
  module Initiatives
    # Example of service to add a signature to a pdf
    class PdfSignatureExample
      attr_accessor :pdf

      # Public: Initializes the service.
      # pdf - The pdf document to be signed
      def initialize(args = {})
        @pdf = args.fetch(:pdf)
      end

      # Public: PDF signed using a new certificate generated by the service
      def signed_pdf
        @signed_pdf ||= begin
          StringIO.open(pdf) do |stream|
            parsed_pdf = Origami::PDF.read(stream)
            parsed_pdf.append_page do |page|
              page.add_annotation(signature_annotation)
              parsed_pdf.sign(
                certificate,
                key,
                method: "adbe.pkcs7.detached",
                annotation: signature_annotation,
                location: location,
                contact: contact,
                issuer: issuer
              )
            end
            extract_signed_pdf(parsed_pdf)
          end
        end
      end

      private

      def extract_signed_pdf(parsed_pdf)
        file = Tempfile.new("signed_pdf")
        begin
          parsed_pdf.save(file.path)
          File.binread(file.path)
        ensure
          file.close
          file.unlink
        end
      end

      def text_annotation(options = {})
        width = options.fetch(:width, 200.0)
        height = options.fetch(:height, 50.0)
        size = options.fetch(:size, 8)

        Origami::Annotation::AppearanceStream.new.tap do |annotation|
          annotation.Type = Origami::Name.new("XObject")
          annotation.Resources = Origami::Resources.new
          annotation.Resources.ProcSet = [Origami::Name.new("Text")]
          annotation.set_indirect(true)
          annotation.Matrix = [1, 0, 0, 1, 0, 0]
          annotation.BBox = [0, 0, width, height]
          annotation.write(caption, x: size, y: (height / 2) - (size / 2), size: size)
        end
      end

      def signature_annotation(options = {})
        @signature_annotation ||= begin
          width = options.fetch(:width, 200.0)
          height = options.fetch(:height, 50.0)

          Origami::Annotation::Widget::Signature.new.tap do |annotation|
            annotation.set_indirect(true)
            annotation.Rect = Origami::Rectangle[llx: height, lly: width + height, urx: width + height, ury: width]
            annotation.set_normal_appearance(text_annotation(width: width, height: height))
          end
        end
      end

      def certificate
        @certificate ||= OpenSSL::X509::Certificate.new.tap do |cert|
          cert.not_before = Time.current
          cert.not_after = 10.years.from_now

          cert.public_key = key.public_key
          cert.sign(key, OpenSSL::Digest.new("SHA256"))
        end
      end

      def key
        @key ||= OpenSSL::PKey::RSA.new(2048)
      end

      def caption
        @caption ||= "Digitally Signed By: #{signedby}\nContact: #{contact}\nLocation: #{location}\nDate: #{date.iso8601}"
      end

      def signedby
        "Test"
      end

      def location
        "Barcelona"
      end

      def contact
        "test@example.org"
      end

      def issuer
        "Decidim"
      end

      def date
        Time.current
      end
    end
  end
end

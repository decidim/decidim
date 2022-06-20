# frozen_string_literal: true

class WickedPdf
  module WickedPdfHelper
    module Assets
      # Force wicked_pdf styles to have a relative path, to prevent fetching
      # them from a host
      def wicked_pdf_stylesheet_pack_tag(*sources)
        stylesheet_pack_tag(*sources)
      end

      # Disables the images in the PDFs as those requests would be jamming under
      # the test environment
      def wicked_pdf_image_tag(img, options = {}); end
    end
  end
end

RSpec.configure do |config|
  config.include WickedPdf::WickedPdfHelper::Assets
end

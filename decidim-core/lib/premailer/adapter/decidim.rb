# frozen_string_literal: true

class Premailer
  module Adapter
    # Decidim adapter for Premailer
    module Decidim
      include ::Premailer::Adapter::Nokogiri

      # Converts the HTML document to a format suitable for plain-text e-mail.
      #
      # If present, uses the <body> element as its base; otherwise uses the whole document.
      #
      # Customized for Decidim in order to strip the inline <style> tags away
      # from the plain text body.
      #
      # @return [String] a plain text.
      def to_plain_text
        html_src = begin
          @doc.css("style").remove
          @doc.at("body").inner_html
        rescue StandardError
          ""
        end

        unless html_src && html_src.present?
          @doc.css("style").remove
          html_src = @doc.to_html
        end

        convert_to_text(html_src, @options[:line_length], @html_encoding)
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module ContentParsers
    # A parser that searches for inline images in an html content and
    # replaces them with EditorImage attachments. Note that rewrite method may
    # create EditorImage instances
    #
    # @see BaseParser Examples of how to use a content parser
    class InlineImagesParser < BaseParser
      # @return [String] the content with the inline images replaced.
      def rewrite
        return content unless inline_images?

        replace_inline_images
        parsed_content.to_html
      end

      def inline_images?
        parsed_content.search(:img).find do |image|
          image.attr(:src).start_with?(%r{data:image/[a-z]{3,4};base64,})
        end
      end

      private

      def parsed_content
        @parsed_content ||= Nokogiri::HTML(content)
      end

      def replace_inline_images
        parsed_content.search(:img).each do |image|
          next unless image.attr(:src).start_with?(%r{data:image/[a-z]{3,4};base64,})

          file = base64_tempfile(image.attr(:src))
          editor_image = EditorImage.create!(
            decidim_author_id: context[:user]&.id,
            organization: context[:user].organization,
            file:
          )

          image.set_attribute(:src, editor_image.attached_uploader(:file).path)
        end
      end

      def base64_tempfile(base64_data, filename = nil)
        return base64_data unless base64_data.is_a? String

        start_regex = %r{data:image/[a-z]{3,4};base64,}
        filename ||= SecureRandom.hex

        regex_result = start_regex.match(base64_data)

        return unless base64_data && regex_result

        start = regex_result.to_s
        tempfile = Tempfile.new(filename)
        tempfile.binmode
        tempfile.write(Base64.decode64(base64_data[start.length..-1]))
        ActionDispatch::Http::UploadedFile.new(
          tempfile:,
          filename:,
          original_filename: filename
        )
      end
    end
  end
end

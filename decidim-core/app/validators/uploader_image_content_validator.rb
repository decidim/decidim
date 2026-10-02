# frozen_string_literal: true

# This validator ensures that files declared as images actually contain valid
# image data. It does so by checking the leading bytes (magic bytes / file
# signature) of the file against the known signatures of the supported image
# formats.
#
# This prevents non-image files (e.g. HTML, MATLAB, or arbitrary binary data)
# from being uploaded with an image extension and a spoofed image content type.
# Such files would later cause image processing to fail (e.g. in ImageMagick
# when generating a variant) and could lead to a denial of service.
class UploaderImageContentValidator < ActiveModel::Validations::FileContentTypeValidator
  # The number of leading bytes to read from the file to detect its signature.
  SIGNATURE_LENGTH = 128

  # The known signatures of the supported binary image formats. Each signature
  # is a list of [offset, bytes] pairs that must all match at their respective
  # offsets for the file to be considered a valid image.
  BINARY_IMAGE_SIGNATURES = [
    [[0, "\x89PNG\r\n\x1A\n".b]], # PNG
    [[0, "\xFF\xD8\xFF".b]], # JPEG
    [[0, "GIF87a".b]], # GIF (GIF87a)
    [[0, "GIF89a".b]], # GIF (GIF89a)
    [[0, "BM".b]], # BMP
    [[0, "II*\x00".b]], # TIFF (little-endian)
    [[0, "MM\x00*".b]], # TIFF (big-endian)
    [[0, "RIFF".b], [8, "WEBP".b]] # WebP
  ].freeze

  # The major brands of the ISOBMFF "ftyp" box that identify HEIF and AVIF
  # images. These formats share the same leading layout as other "ftyp" files
  # (e.g. MP4 video), so the brand at offset 8 is used to tell images apart.
  FTYPE_IMAGE_BRANDS = %w(heic heix hevc hevx mif1 msf1 avif avis).map(&:b).freeze

  # The leading markup of an SVG document, which is XML-based and therefore has
  # no fixed binary signature.
  SVG_SIGNATURES = ["<svg".b, "<?xml".b, "<!DOCTYPE svg".b].freeze

  def validate_each(record, attribute, value)
    begin
      values = parse_values(value)
    rescue JSON::ParserError
      record.errors.add attribute, :invalid
      return
    end

    return if values.empty?

    values.each do |val|
      validate_image_content(record, attribute, val)
    end
  end

  def check_validity!; end

  private

  def validate_image_content(record, attribute, file)
    return unless image_content_type?(file)

    signature = file_signature(file)
    return if signature.nil?

    record.errors.add attribute, I18n.t("decidim.errors.files.file_is_not_a_valid_image") unless valid_image_signature?(signature)
  end

  # Whether the file is declared as an image based on its content type.
  def image_content_type?(file)
    content_type =
      if file.is_a?(ActiveStorage::Attached)
        file.blob&.content_type
      else
        file.try(:content_type)
      end

    content_type.to_s.start_with?("image/")
  end

  # Reads the leading bytes (signature) of the file. Returns nil when the file
  # cannot be read, in which case the validation is skipped.
  def file_signature(file)
    if uploaded_file?(file)
      File.open(file.path, "rb") { |io| io.read(SIGNATURE_LENGTH) }
    elsif file.is_a?(ActiveStorage::Attached) && file.blob.persisted?
      blob_signature(file.blob)
    end
  rescue ActiveStorage::Error, Errno::ENOENT, IOError
    nil
  end

  # Reads only the leading bytes of the blob to keep the operation cheap for
  # large files. Falls back to opening the whole blob when the service does not
  # support ranged downloads.
  def blob_signature(blob)
    blob.download_chunk(0...SIGNATURE_LENGTH)
  rescue NotImplementedError
    blob.open { |io| io.read(SIGNATURE_LENGTH) }
  end

  def valid_image_signature?(signature)
    return false if signature.blank?

    binary_image_signature?(signature) || ftyp_image_brand?(signature) || svg_signature?(signature)
  end

  def binary_image_signature?(signature)
    BINARY_IMAGE_SIGNATURES.any? do |pairs|
      pairs.all? { |offset, bytes| signature[offset, bytes.bytesize] == bytes }
    end
  end

  # Whether the file is an ISOBMFF-based image (HEIF or AVIF). These files start
  # with a "ftyp" box at offset 4 followed by a major brand at offset 8.
  def ftyp_image_brand?(signature)
    return false unless signature[4, 4] == "ftyp".b

    FTYPE_IMAGE_BRANDS.any? { |brand| signature[8, 4] == brand }
  end

  def svg_signature?(signature)
    content = signature.sub(/\A\xEF\xBB\xBF/n, "").lstrip
    SVG_SIGNATURES.any? { |svg_signature| content.start_with?(svg_signature) }
  end

  def uploaded_file?(file)
    return true if defined?(Rack::Test::UploadedFile) && file.is_a?(Rack::Test::UploadedFile)

    file.is_a?(ActionDispatch::Http::UploadedFile)
  end
end

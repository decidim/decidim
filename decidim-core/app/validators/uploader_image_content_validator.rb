# frozen_string_literal: true

# This validator ensures that files declared as images actually contain valid
# image data of the declared format. It does so by checking the leading bytes
# (magic bytes / file signature) of the file against the known signatures of
# the supported image formats, and by comparing the detected format with the
# content type declared by the file.
#
# This prevents non-image files (e.g. HTML, MATLAB, or arbitrary binary data)
# from being uploaded with an image extension and a spoofed image content type.
# Such files would later cause image processing to fail (e.g. in ImageMagick
# when generating a variant) and could lead to a denial of service.
#
# Comparing the detected format with the declared content type also prevents
# files whose contents do not match their declaration (e.g. a JPEG file
# declared as image/png), so that the stored MIME type is consistent with the
# file contents.
class UploaderImageContentValidator < ActiveModel::Validations::FileContentTypeValidator
  # The number of leading bytes to read from the file to detect its signature.
  SIGNATURE_LENGTH = 128

  # The known signatures of the supported binary image formats. Each entry
  # associates a format with a list of [offset, bytes] pairs that must all
  # match at their respective offsets for the file to be considered of that
  # format.
  BINARY_IMAGE_SIGNATURES = [
    [:png, [[0, "\x89PNG\r\n\x1A\n".b]]],
    [:jpeg, [[0, "\xFF\xD8\xFF".b]]],
    [:gif, [[0, "GIF87a".b]]],
    [:gif, [[0, "GIF89a".b]]],
    [:bmp, [[0, "BM".b]]],
    [:tiff, [[0, "II*\x00".b]]],
    [:tiff, [[0, "MM\x00*".b]]],
    [:webp, [[0, "RIFF".b], [8, "WEBP".b]]]
  ].freeze

  # The major brands of the ISOBMFF "ftyp" box that identify HEIF and AVIF
  # images. These formats share the same leading layout as other "ftyp" files
  # (e.g. MP4 video), so the brand at offset 8 is used to tell images apart.
  # The brands are grouped per format family, because HEIF files may use any
  # of the HEIF brands regardless of their extension (e.g. a ".heic" file
  # with the "mif1" major brand).
  FTYPE_IMAGE_BRANDS = {
    heif: %w(heic heix hevc hevx mif1 msf1).map(&:b).freeze,
    avif: %w(avif avis).map(&:b).freeze
  }.freeze

  # The leading markup of an SVG document, which is XML-based and therefore has
  # no fixed binary signature.
  SVG_SIGNATURES = ["<svg".b, "<?xml".b, "<!DOCTYPE svg".b].freeze

  # The content types accepted for each image format detected from the file
  # signature. The content type declared by the file must be one of these, so
  # that the stored MIME type is consistent with the file contents. The lists
  # include the aliases commonly used in the wild for the same format.
  FORMAT_CONTENT_TYPES = {
    png: %w(image/png),
    jpeg: %w(image/jpeg image/jpg image/pjpeg),
    gif: %w(image/gif),
    bmp: %w(image/bmp image/x-ms-bmp image/windows-bmp),
    tiff: %w(image/tiff image/x-tiff),
    webp: %w(image/webp),
    heif: %w(image/heic image/heif image/heic-sequence image/heif-sequence),
    avif: %w(image/avif image/avis),
    svg: %w(image/svg+xml)
  }.freeze

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
    content_type = normalize_content_type(declared_content_type(file))
    return unless content_type.start_with?("image/")

    signature = file_signature(file)
    return if signature.nil?

    return if valid_image_content?(content_type, signature)

    record.errors.add attribute, I18n.t("decidim.errors.files.file_is_not_a_valid_image")
  end

  # The content type declared by the file, either through the blob of an
  # attached file or through the upload itself.
  def declared_content_type(file)
    if file.is_a?(ActiveStorage::Attached)
      file.blob&.content_type
    else
      file.try(:content_type)
    end
  end

  # Strips the content type parameters (e.g. "image/png;charset=binary") and
  # normalizes the casing, as content types are case insensitive.
  def normalize_content_type(content_type)
    content_type.to_s.split(";", 2).first.to_s.strip.downcase
  end

  # Whether the signature matches one of the supported image formats and the
  # detected format is consistent with the content type declared by the file.
  def valid_image_content?(content_type, signature)
    detected = image_format(signature)
    return false if detected.nil?

    FORMAT_CONTENT_TYPES.fetch(detected).include?(content_type)
  end

  # Reads the leading bytes (signature) of the file. Returns nil when the file
  # cannot be read, in which case the validation is skipped.
  def file_signature(file)
    if uploaded_file?(file)
      File.open(file.path, "rb") { |io| io.read(SIGNATURE_LENGTH) }
    elsif file.is_a?(ActiveStorage::Attached)
      attached_signature(file)
    end
  rescue ActiveStorage::Error, Errno::ENOENT, IOError
    nil
  end

  # Reads the signature of an attached file. Blobs are only uploaded once the
  # record is saved, so for still unpersisted blobs (e.g. an image assigned to
  # a new record) the bytes are read from the pending attachable instead.
  # Otherwise a spoofed image could be saved without being checked.
  def attached_signature(attached)
    blob = attached.blob
    return blob_signature(blob) if blob&.persisted?

    pending_attachable_signature(attached)
  end

  # ActiveStorage keeps the attachable of a pending attachment in the record's
  # attachment changes until the blob is uploaded when the record is saved, so
  # its contents can already be read during the validation.
  def pending_attachable_signature(attached)
    attachable = pending_attachable(attached)
    if uploaded_file?(attachable) || attachable.is_a?(File)
      File.open(attachable.path, "rb") { |io| io.read(SIGNATURE_LENGTH) }
    elsif attachable.is_a?(Pathname)
      File.open(attachable.to_path, "rb") { |io| io.read(SIGNATURE_LENGTH) }
    elsif attachable.is_a?(Hash)
      io_signature(attachable[:io])
    end
  end

  def pending_attachable(attached)
    change = attached.record.try(:attachment_changes)&.[](attached.name.to_s)
    change.try(:attachable)
  end

  # Reads the signature without consuming the IO, so ActiveStorage can still
  # upload it after the validation.
  def io_signature(io)
    return unless io.respond_to?(:read) && io.respond_to?(:rewind)

    io.rewind
    signature = io.read(SIGNATURE_LENGTH)
    io.rewind
    signature
  end

  # Reads only the leading bytes of the blob to keep the operation cheap for
  # large files. Falls back to opening the whole blob when the service does not
  # support ranged downloads.
  def blob_signature(blob)
    blob.download_chunk(0...SIGNATURE_LENGTH)
  rescue NotImplementedError
    blob.open { |io| io.read(SIGNATURE_LENGTH) }
  end

  # The image format detected from the file signature, or nil when the
  # signature does not match any of the supported image formats.
  def image_format(signature)
    return nil if signature.blank?

    binary_image_format(signature) || ftyp_image_format(signature) || svg_format(signature)
  end

  def binary_image_format(signature)
    BINARY_IMAGE_SIGNATURES.find do |_format, pairs|
      pairs.all? { |offset, bytes| signature[offset, bytes.bytesize] == bytes }
    end&.first
  end

  # The format of an ISOBMFF-based image (HEIF or AVIF). These files start with
  # a "ftyp" box at offset 4 followed by a major brand at offset 8.
  def ftyp_image_format(signature)
    return nil unless signature[4, 4] == "ftyp".b

    FTYPE_IMAGE_BRANDS.find { |_format, brands| brands.include?(signature[8, 4]) }&.first
  end

  def svg_format(signature)
    content = signature.sub(/\A\xEF\xBB\xBF/n, "").lstrip
    return nil unless SVG_SIGNATURES.any? { |svg_signature| content.start_with?(svg_signature) }

    :svg
  end

  def uploaded_file?(file)
    return true if defined?(Rack::Test::UploadedFile) && file.is_a?(Rack::Test::UploadedFile)

    file.is_a?(ActionDispatch::Http::UploadedFile)
  end
end

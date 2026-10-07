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
#
# SVG documents are XML-based and can contain scripts and other active content,
# which is executed when the document is rendered by the browser. Because of
# that, the contents of files detected as SVG are additionally validated, so
# that documents which could execute scripts or read external resources are
# rejected instead of being stored as they are.
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

  # The elements which are not allowed in SVG documents, because they either
  # execute scripts themselves (e.g. "script" and the SVG Tiny "handler") or
  # allow embedding foreign content which can execute them (e.g.
  # "foreignObject"). The names are kept in lowercase, as the names found in
  # the documents are compared case insensitively.
  SVG_FORBIDDEN_ELEMENTS = %w(script handler foreignobject iframe embed object applet).freeze

  # The names of the attributes which are not allowed in SVG documents, as
  # event handlers execute scripts when the document is rendered.
  SVG_EVENT_HANDLER_NAME = /\Aon[a-z]/i

  # The URI prefixes which are not allowed in the attribute values of SVG
  # documents, as they execute scripts.
  SVG_FORBIDDEN_URI_PREFIXES = %w(javascript: livescript: vbscript: data:text/html).freeze

  # The attributes of the SVG animation elements which define the attribute
  # modified by the animation. Through them an animation can set an event
  # handler or another forbidden value at runtime, so the values of these
  # attributes are validated as element/attribute names.
  SVG_ANIMATION_TARGET_NAMES = %w(attribute attributeName attributeNames).freeze

  # The CSS at-rules and functions which load external resources when the
  # style sheets of an SVG document are rendered. Imports always fetch a
  # resource, and URL references with a scheme (e.g. "https:") or a
  # protocol-relative host (e.g. "//example.org") fetch one from another
  # host, so documents containing them are rejected. Fragment ("#") and
  # relative references are resolved against the document itself, and
  # "data:" references are inline, so they are accepted.
  SVG_CSS_IMPORT = /@import/i
  SVG_CSS_EXTERNAL_URL = %r{url\(\s*["']?\s*(?!data:)(?:[a-z][a-z0-9+.-]*:|//)}i

  # The declaration of entities in the document type definition of an SVG
  # document. Entities can be used to read external resources (XXE) or to
  # expand content exponentially (billion laughs), so documents declaring them
  # are rejected. External DTD references without entity declarations are
  # accepted, as the DTDs are never fetched (see #parse_svg).
  SVG_ENTITY_DECLARATION = /<!ENTITY/i

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

    detected = image_format(signature)
    return add_invalid_image(record, attribute) unless valid_image_format?(detected, content_type)

    validate_svg_content(record, attribute, file) if detected == :svg
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

  # Whether the format detected from the file signature is one of the
  # supported image formats and is consistent with the content type declared
  # by the file.
  def valid_image_format?(detected, content_type)
    return false if detected.nil?

    FORMAT_CONTENT_TYPES.fetch(detected).include?(content_type)
  end

  # Validates the contents of an SVG document, which can contain active
  # content. The document must be parseable as XML with an "svg" root element
  # and must not declare entities nor contain any other content which could
  # execute scripts or read external resources when the document is rendered.
  def validate_svg_content(record, attribute, file)
    content = file_content(file)
    return add_invalid_image(record, attribute) if content.blank?
    return add_unsafe_svg(record, attribute) if SVG_ENTITY_DECLARATION.match?(content)

    document = parse_svg(content)
    return add_invalid_image(record, attribute) if document.nil?
    return add_unsafe_svg(record, attribute) if forbidden_svg_content?(document)

    true
  end

  # Parses the SVG document without fetching any external resource (e.g. an
  # external DTD) and without substituting entities, so that a malicious
  # document cannot make the server read external resources or expand entities
  # while it is validated. Returns nil when the contents are not a well formed
  # XML document with an "svg" root element.
  def parse_svg(content)
    document = Nokogiri::XML.parse(content, &:nonet)
    return nil if document.root.nil? || document.root.name != "svg"

    document
  rescue Nokogiri::XML::SyntaxError
    nil
  end

  def forbidden_svg_content?(document)
    # The "xml-stylesheet" processing instruction loads an external style
    # sheet when the document is rendered, so documents declaring one are
    # rejected.
    return true if document.xpath("//processing-instruction('xml-stylesheet')").any?

    document.xpath("//*").any? { |node| forbidden_svg_node?(node) }
  end

  def forbidden_svg_node?(node)
    return true if SVG_FORBIDDEN_ELEMENTS.include?(node.name.downcase)
    return true if node.attribute_nodes.any? { |attribute| forbidden_svg_attribute?(attribute) }

    node.name.downcase == "style" && forbidden_css_content?(node.content.to_s)
  end

  def forbidden_svg_attribute?(attribute)
    return true if SVG_EVENT_HANDLER_NAME.match?(attribute.name)

    return true if forbidden_uri_value?(attribute.value.to_s)
    return true if attribute.name.downcase == "style" && forbidden_css_content?(attribute.value.to_s)

    SVG_ANIMATION_TARGET_NAMES.include?(attribute.name) && forbidden_svg_name?(attribute.value.to_s)
  end

  # Whether the value is a script URI or contains one. The animation elements
  # accept lists of values separated by semicolons (e.g. in the "values"
  # attribute), which are assigned to the target attribute one after another
  # at runtime, so each value of the list is checked separately.
  def forbidden_uri_value?(value)
    value.split(";").any? do |uri|
      normalized = normalize_uri_value(uri)
      SVG_FORBIDDEN_URI_PREFIXES.any? { |prefix| normalized.start_with?(prefix) }
    end
  end

  # Whether the value targets an event handler or a forbidden element, as
  # used by the animation elements to modify attributes at runtime. Lists of
  # names are also accepted by some animation attributes, so each name of the
  # list is checked separately.
  def forbidden_svg_name?(name)
    name.split(";").any? do |part|
      normalized = part.strip.downcase
      SVG_EVENT_HANDLER_NAME.match?(normalized) || SVG_FORBIDDEN_ELEMENTS.include?(normalized)
    end
  end

  # Whether the CSS of a "style" element or attribute loads external
  # resources when the document is rendered. The comments are removed and the
  # escape sequences decoded before checking, as they can otherwise hide the
  # references (e.g. "u\rl(https://example.org)").
  def forbidden_css_content?(css)
    normalized = decode_css_escapes(css.gsub(%r{/\*.*?\*/}m, ""))
    SVG_CSS_IMPORT.match?(normalized) || SVG_CSS_EXTERNAL_URL.match?(normalized)
  end

  # Decodes the escape sequences of CSS, which consist of a backslash
  # followed by up to six hexadecimal digits (with an optional whitespace
  # terminating the sequence) or by any other character. Invalid codepoints
  # are replaced with the replacement character.
  def decode_css_escapes(css)
    css.gsub(/\\(?:(\h{1,6})[ \t\n\r\f]?|(.))/m) do
      digits = Regexp.last_match(1)
      next Regexp.last_match(2) if digits.nil?

      codepoint = digits.to_i(16)
      if codepoint.zero? || codepoint > 0x10FFFF || codepoint.between?(0xD800, 0xDFFF)
        "\uFFFD"
      else
        [codepoint].pack("U")
      end
    end
  end

  # Removes the whitespace and control characters which can be used to
  # obfuscate URI schemes (e.g. "java\tscript:") and normalizes the casing.
  def normalize_uri_value(value)
    value.gsub(/[[:space:][:cntrl:]]/, "").downcase
  end

  def add_invalid_image(record, attribute)
    record.errors.add attribute, I18n.t("decidim.errors.files.file_is_not_a_valid_image")
  end

  def add_unsafe_svg(record, attribute)
    record.errors.add attribute, I18n.t("decidim.errors.files.file_contains_unsafe_content")
  end

  # Reads the leading bytes (signature) of the file. Returns nil when the file
  # cannot be read, in which case the validation is skipped. Empty files yield
  # an empty signature, which is rejected.
  def file_signature(file)
    read_file(file, SIGNATURE_LENGTH)
  end

  # Reads the whole contents of the file. Returns nil when the file cannot be
  # read.
  def file_content(file)
    read_file(file)
  end

  # Reads the contents of the file, or only its leading bytes when a maximum
  # length is given.
  def read_file(file, max_length = nil)
    if uploaded_file?(file)
      File.open(file.path, "rb") { |io| read_io(io, max_length) }
    elsif file.is_a?(ActiveStorage::Attached)
      read_attached(file, max_length)
    end
  rescue ActiveStorage::Error, Errno::ENOENT, IOError
    nil
  end

  # Reads the contents of an IO, or only its leading bytes when a maximum
  # length is given. IO#read returns nil at the end of the file, so an empty
  # file would otherwise be indistinguishable from an unreadable one and skip
  # the validation. Normalizing it to an empty content keeps empty files
  # rejected, while nil is kept for files which cannot be read at all.
  def read_io(io, max_length = nil)
    (max_length ? io.read(max_length) : io.read) || ""
  end

  # Reads the contents of an attached file. Blobs are only uploaded once the
  # record is saved, so for still unpersisted blobs (e.g. an image assigned to
  # a new record) the bytes are read from the pending attachable. Otherwise a
  # spoofed image could be saved without being checked.
  def read_attached(attached, max_length = nil)
    blob = attached.blob
    return read_blob(blob, max_length) if blob&.persisted?

    read_pending_attachable(attached, max_length)
  end

  # ActiveStorage keeps the attachable of a pending attachment in the record's
  # attachment changes until the blob is uploaded when the record is saved, so
  # its contents can already be read during the validation.
  def read_pending_attachable(attached, max_length = nil)
    attachable = pending_attachable(attached)
    if uploaded_file?(attachable) || attachable.is_a?(File)
      File.open(attachable.path, "rb") { |io| read_io(io, max_length) }
    elsif attachable.is_a?(Pathname)
      File.open(attachable.to_path, "rb") { |io| read_io(io, max_length) }
    elsif attachable.is_a?(Hash)
      read_io_without_consuming(attachable[:io], max_length)
    end
  end

  def pending_attachable(attached)
    change = attached.record.try(:attachment_changes)&.[](attached.name.to_s)
    change.try(:attachable)
  end

  # Reads the contents without consuming the IO, so ActiveStorage can still
  # upload it after the validation.
  def read_io_without_consuming(io, max_length = nil)
    return unless io.respond_to?(:read) && io.respond_to?(:rewind)

    io.rewind
    content = read_io(io, max_length)
    io.rewind
    content
  end

  # Reads the whole contents of the blob, or only its leading bytes when a
  # maximum length is given to keep the operation cheap for large files. The
  # services return nil when the blob is empty, which is normalized to an
  # empty content so that empty blobs are rejected. Falls back to opening the
  # whole blob when the service does not support ranged downloads.
  def read_blob(blob, max_length = nil)
    return blob.download if max_length.nil?

    blob.download_chunk(0...max_length) || ""
  rescue NotImplementedError
    blob.open { |io| read_io(io, max_length) }
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

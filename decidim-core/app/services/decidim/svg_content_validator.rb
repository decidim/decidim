# frozen_string_literal: true

require "strscan"

module Decidim
  # Validates the contents of SVG documents.
  #
  # SVG documents are XML-based and can contain scripts and other active
  # content, which is executed when the document is rendered by the browser.
  # Because of that, the contents of files detected as SVG need an additional
  # validation, so that documents which could execute scripts or read external
  # resources are rejected instead of being stored as they are.
  #
  # The document must be parseable as XML with an "svg" root element and must
  # not declare entities nor contain any other content which could execute
  # scripts or read external resources when the document is rendered.
  #
  # The references which load resources into the document (the "href" of
  # "image", "use", "feImage" and "cursor", the URL references of the
  # presentation attributes, the style sheets and the "xml-stylesheet"
  # instruction) are restricted to the document itself and to inline data, so
  # that documents cannot make the browser of the reader fetch third-party
  # resources. The contents of the inline data references declaring
  # an SVG document are validated as nested documents, as they are parsed when
  # the reference is rendered. Links ("a") are not restricted, as they do not
  # load any resource when the document is rendered; they can still reference
  # any host, so they are a phishing surface which is accepted on purpose.
  #
  # This is used by UploaderImageContentValidator, which delegates the SVG
  # specific validation to this class, so callers of that validator only need
  # to call a single validator for all the image formats.
  class SvgContentValidator
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
    # attributes are validated as element/attribute names. The names are kept
    # in lowercase and compared case insensitively, as the HTML parser resolves
    # the names written in lowercase (e.g. "attributename") to the camel case
    # ones when the document is parsed as HTML.
    SVG_ANIMATION_TARGET_NAMES = %w(attribute attributename attributenames).freeze

    # The elements which load the resource referenced by their "href" (or
    # legacy "xlink:href") attribute into the document when it is rendered.
    # The references of these elements are restricted to the document itself
    # and to inline data, as absolute references make the browser of the
    # reader fetch resources from third-party hosts, which can be used for
    # tracking or for probing internal networks. Links ("a") are not
    # included, as they do not load any resource; they can still reference
    # any host, so they are a phishing surface which is accepted on purpose.
    SVG_RESOURCE_ELEMENTS = %w(image use feimage cursor).freeze

    # The presentation attributes whose value defines a reference resolved when
    # the document is rendered. The image references (e.g. "cursor" and "mask")
    # are fetched as resources, and the references to paint servers, filters,
    # clipping paths and markers can also resolve to an element of another
    # document, which is fetched unless the document is processed in a secure
    # mode. Their values are validated as style sheet content, as they are
    # parsed as the CSS properties they define.
    SVG_URL_PRESENTATION_ATTRIBUTES = %w(
      cursor mask fill stroke filter clip-path marker marker-start marker-mid marker-end
    ).freeze

    # The name of the attribute which references the resource loaded by an
    # element, either "href" or the legacy "xlink:href", which is also
    # matched with an undeclared prefix, as browsers resolve it as the XLink
    # reference.
    SVG_REFERENCE_NAME = /\A(?:[\w.-]+:)?href\z/i

    # The references which load a resource from another host: URIs with a
    # scheme (e.g. "https:") and references resolving to an authority, which
    # browsers also detect from two separators at the beginning of the
    # reference (e.g. "//example.org", "/\example.org" or "\\example.org"), as
    # backslashes are treated as separators of the authority for the schemes of
    # the web. A single backslash only starts a path, so it is not matched.
    # Fragment ("#") and relative references are resolved against the document
    # itself, and "data:" references are inline, so they are accepted (see
    # #forbidden_reference_value?).
    SVG_EXTERNAL_REFERENCE = %r{\A(?!data:)(?:[a-z][a-z0-9+.-]*:|[\\/]{2})}i

    # The inline data references whose contents are parsed when the document is
    # rendered. The SVG ones are validated as nested documents, as the rules
    # above cannot be applied to a payload which is stored encoded (e.g. in
    # base64), and the other ones are accepted when they do not declare a
    # forbidden content type (see SVG_FORBIDDEN_URI_PREFIXES). The parameters of
    # the MIME type (e.g. "image/svg+xml;charset=utf-8") are matched as well, as
    # browsers still parse the payload as a document, and the "base64" one can
    # appear in any position of the list.
    SVG_DATA_URI = %r{\Adata:(?<mime>image/svg\+xml)(?<parameters>(?:;[^;,]*)*),(?<payload>.*)\z}im

    # The CSS functions which load the resources they reference when the style
    # sheet is rendered. The strings inside them are interpreted as URLs, so the
    # arguments of "image-set()" define a reference as the arguments of "url()"
    # do, and the vendor prefixed spelling is matched as well.
    CSS_URL_FUNCTIONS = %w(url image-set -webkit-image-set).freeze

    # The URL references of a style sheet, captured after the comments and the
    # strings which do not define a URL are removed, so that each of them can
    # be validated as a reference. Only the strings of the functions which load
    # their arguments survive the scrubbing, so the remaining strings are URL
    # values, and the unquoted value of a "url()" function is matched as well.
    SVG_CSS_URL_VALUE = /["']([^"')]+)["']?|(?:url|image-set)\(\s*([^"')]+)/im

    # The maximum depth of the documents nested inside inline data references,
    # which are validated with the same rules as the document itself.
    MAX_NESTED_DEPTH = 5

    # The maximum size of the contents to validate, as a safety net for the
    # documents which reach this validator without a size limit.
    MAX_CONTENT_SIZE = 10 * 1024 * 1024

    # The elements which modify the attributes of another element at runtime.
    # When they target a reference attribute of an element which loads the
    # referenced resource, the values assigned to it are validated as
    # references, as the resource is loaded when the animation reaches it. When
    # they target the "style" attribute, the values are validated as style
    # sheet content, as the URL references they declare are loaded when the
    # animation reaches them.
    SVG_ANIMATION_ELEMENTS = %w(animate set).freeze
    SVG_ANIMATION_VALUE_NAMES = %w(values from to by).freeze

    # The CSS at-rules which load external resources when the style sheets of
    # an SVG document are rendered. Imports always fetch a resource, so
    # documents containing them are rejected. The URL references are validated
    # separately as references (see SVG_CSS_URL_VALUE), as the same rules apply
    # to them: references with a scheme or an authority fetch a resource from
    # another host, fragment and relative references are resolved against the
    # document itself, and "data:" references are inline but can contain a
    # nested document which is parsed when rendered.
    SVG_CSS_IMPORT = /@import/i

    # The escape sequences of CSS, which consist of a backslash followed by up
    # to six hexadecimal digits, with an optional whitespace terminating the
    # sequence, or by any other character.
    CSS_ESCAPE = /\\(?:(?<hex>\h{1,6})[ \t\n\r\f]?|(?<char>.))/m

    # Validates the contents of an SVG document. Returns :valid when the
    # document can be stored, :invalid when the contents are not a well formed
    # SVG document, and :unsafe when the document contains content which could
    # execute scripts or read external resources when it is rendered.
    def self.validate(content)
      new(content).validate
    end

    def initialize(content, depth = 0)
      @content = content
      @depth = depth
    end

    def validate
      return :invalid if content.nil?
      # The contents which are not valid in their encoding cannot be checked by
      # the expressions below, so they are rejected as unsafe.
      return :unsafe unless content.valid_encoding?
      return :invalid if content.blank?
      return :invalid if content.bytesize > MAX_CONTENT_SIZE

      document = parse
      return :invalid if document.nil?
      return :unsafe if entity_declaration?(document)
      return :unsafe if forbidden_content?(document)

      :valid
    end

    private

    attr_reader :content, :depth

    # Parses the SVG document in strict mode, so that malformed documents are
    # rejected instead of being recovered with a partial tree, and without
    # fetching any external resource (e.g. an external DTD) or substituting
    # entities, so that a malicious document cannot make the server read external
    # resources or expand entities while it is validated. Returns nil when the
    # contents are not a well formed XML document with an "svg" root element.
    def parse
      document = Nokogiri::XML.parse(content) { |options| options.strict.nonet }
      return nil if document.root.nil? || document.root.name != "svg"

      document
    rescue Nokogiri::XML::SyntaxError
      nil
    end

    def forbidden_content?(document)
      # The "xml-stylesheet" processing instruction loads an external style
      # sheet when the document is rendered, so documents declaring one are
      # rejected.
      return true if document.xpath("//processing-instruction('xml-stylesheet')").any?

      document.xpath("//*").any? { |node| forbidden_node?(node) }
    end

    def forbidden_node?(node)
      return true if SVG_FORBIDDEN_ELEMENTS.include?(node.name.downcase)
      return true if node.attribute_nodes.any? { |attribute| forbidden_attribute?(node, attribute) }
      return true if forbidden_animation_reference?(node)

      node.name.downcase == "style" && forbidden_css_content?(node.content.to_s)
    end

    def forbidden_attribute?(node, attribute)
      return true if SVG_EVENT_HANDLER_NAME.match?(attribute.name)

      return true if forbidden_uri_value?(attribute.value.to_s)
      return true if css_content_attribute?(attribute) && forbidden_css_content?(attribute.value.to_s)
      return true if animation_target_attribute?(attribute) && forbidden_name?(attribute.value.to_s)

      forbidden_resource_reference?(node, attribute)
    end

    # Whether the value of the attribute is parsed as the content of a style
    # sheet, either because it declares the declarations of an element or
    # because it is a presentation attribute whose CSS property resolves a URL
    # reference (see SVG_URL_PRESENTATION_ATTRIBUTES).
    def css_content_attribute?(attribute)
      name = attribute.name.downcase
      name == "style" || SVG_URL_PRESENTATION_ATTRIBUTES.include?(name)
    end

    # Whether the attribute references an external resource in an element
    # which loads it when the document is rendered (e.g. the "href" of an
    # "image").
    def forbidden_resource_reference?(node, attribute)
      return false unless resource_element?(node)
      return false unless SVG_REFERENCE_NAME.match?(attribute.name)

      forbidden_reference_value?(attribute.value.to_s)
    end

    # Whether an animation assigns an external resource to a reference
    # attribute (e.g. "href") of an element which loads it, as the resource
    # is loaded when the animation reaches the value. References which do not
    # load a resource (e.g. the links of an "a") are not restricted, as they
    # are never fetched when the document is rendered. The values assigned to
    # the "style" attribute are validated as style sheet content, as the URL
    # references they declare are loaded when the animation reaches them.
    def forbidden_animation_reference?(node)
      return false unless SVG_ANIMATION_ELEMENTS.include?(node.name.downcase)

      target = animation_target(node)
      values = animation_values(node)
      return false if target.nil? || values.empty?

      return true if target == "style" && forbidden_css_values?(values)
      return false unless SVG_REFERENCE_NAME.match?(target) && animates_resource_element?(node)

      forbidden_reference_values?(values)
    end

    def forbidden_css_values?(values)
      values.any? { |value| forbidden_css_content?(value) }
    end

    def forbidden_reference_values?(values)
      values.any? { |value| forbidden_reference_value?(value) }
    end

    # The attribute modified by an animation, normalized as the HTML parser
    # resolves it when the document is parsed as HTML.
    def animation_target(node)
      attribute = node.attribute_nodes.find { |a| animation_target_attribute?(a) }
      attribute&.value&.downcase
    end

    def animation_target_attribute?(attribute)
      SVG_ANIMATION_TARGET_NAMES.any? { |name| attribute.name.casecmp?(name) }
    end

    # The values assigned by an animation, which are accepted as lists
    # separated by semicolons.
    def animation_values(node)
      SVG_ANIMATION_VALUE_NAMES.flat_map { |name| node[name].to_s.split(";") }
    end

    # Whether the animation modifies the reference of an element which loads
    # the referenced resource when the document is rendered. The animation
    # modifies its parent element, unless it references another one with its
    # own reference attribute (e.g. "xlink:href"), which browsers resolve to
    # the element with that identifier. References which do not resolve to an
    # element of the document are also considered as loading a resource, so
    # that documents which could hide the modified element are rejected.
    def animates_resource_element?(node)
      references = node.attribute_nodes.select { |attribute| SVG_REFERENCE_NAME.match?(attribute.name) }
      return resource_element?(node.parent) if references.empty?

      references.any? do |attribute|
        targets = referenced_elements(node.document, attribute.value.to_s)
        targets.empty? || targets.any? { |element| resource_element?(element) }
      end
    end

    # The elements of the document referenced by a target reference of an
    # animation element, which browsers resolve to the element with the
    # identifier of the fragment, after decoding its percent-encoded characters.
    # The decoded identifier is encoded as UTF-8, as the identifiers of the
    # document are read with that encoding. References to other documents or to
    # missing identifiers do not resolve to any element.
    def referenced_elements(document, reference)
      id = reference[/\A#(.*)\z/m, 1]
      return [] if id.nil?

      elements_by_id(document).fetch(percent_decode(id).force_encoding(Encoding::UTF_8), [])
    end

    # The elements of the document which declare an identifier, grouped by it.
    # The index is built once per document and reused for every reference, as
    # searching the whole document for each of the animations would take a
    # long time for documents with many elements and animations.
    def elements_by_id(document)
      @elements_by_id ||= {}
      @elements_by_id[document] ||= document.xpath("//*[@id]").group_by { |element| element["id"] }
    end

    # Whether the element loads the resource referenced by its reference
    # attribute when the document is rendered.
    def resource_element?(element)
      SVG_RESOURCE_ELEMENTS.include?(element.name.downcase)
    end

    # Whether the reference loads a resource from another host or contains a
    # nested document which could execute scripts or read external resources
    # when it is rendered. The whitespace and control characters which can be
    # used to obfuscate the scheme are removed before checking.
    def forbidden_reference_value?(value)
      return true if SVG_EXTERNAL_REFERENCE.match?(normalize_uri_value(value))
      return true if forbidden_uri_value?(value)

      nested_document_unsafe?(value)
    end

    # Whether the contents of an inline data reference declaring an SVG
    # document are unsafe, as they are parsed as a document of their own when
    # the reference is rendered. The nested documents are validated with the
    # same rules, up to a maximum depth, so that a document referencing itself
    # cannot be used to recurse indefinitely. A nested document which cannot be
    # validated because the maximum depth is reached is rejected, as its contents
    # are still parsed when the reference is rendered.
    def nested_document_unsafe?(value)
      match = SVG_DATA_URI.match(value.strip)
      return false if match.nil?
      return true if depth >= MAX_NESTED_DEPTH

      payload = match[:parameters].downcase.include?(";base64") ? decode_base64(match[:payload]) : percent_decode(match[:payload])
      Decidim::SvgContentValidator.new(payload, depth + 1).validate == :unsafe
    end

    def decode_base64(value)
      value.unpack1("m")
    end

    # Decodes the percent-encoded characters of a data URI, which are otherwise
    # invisible to the checks applied to the contents of the document. The
    # substitutions are applied to the bytes of the value, as the decoded
    # characters can be part of a multi-byte sequence which is not valid in the
    # encoding of the value. The result is kept as bytes, so that the encoding
    # declared by a nested document is still read by the parser (see #parse);
    # the callers which compare the decoded value with the contents of the
    # document encode it as UTF-8.
    def percent_decode(value)
      value.dup.force_encoding(Encoding::BINARY).gsub(/%([0-9A-Fa-f]{2})/) { [Regexp.last_match(1).hex].pack("C") }
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
    def forbidden_name?(name)
      name.split(";").any? do |part|
        normalized = part.strip.downcase
        SVG_EVENT_HANDLER_NAME.match?(normalized) || SVG_FORBIDDEN_ELEMENTS.include?(normalized)
      end
    end

    # Whether the document type definition declares an entity. Entities can be
    # used to read external resources (XXE) or to expand content exponentially
    # (billion laughs), so documents declaring one are rejected. Only the
    # declarations of the internal subset are considered, as the external ones
    # are never fetched (see #parse). Text which only looks like a declaration
    # outside of the document type definition (e.g. inside a comment, a CDATA
    # section or a processing instruction) is not a declaration, so it does not
    # reject a legitimate document.
    def entity_declaration?(document)
      internal_subset = document.internal_subset
      return false if internal_subset.nil?

      internal_subset.children.any? { |node| node.type == Nokogiri::XML::Node::ENTITY_DECL }
    end

    # Whether the CSS of a "style" element or attribute loads external
    # resources when the document is rendered. The comments and the strings
    # which do not define a URL are removed, and the escape sequences decoded,
    # before checking, as they can otherwise hide the references (e.g.
    # "u\rl(https://example.org)") or be mistaken for them (e.g. 'content:
    # "See @import instructions"').
    def forbidden_css_content?(css)
      normalized = decode_css_escapes(scrub_css(css))
      return true if SVG_CSS_IMPORT.match?(normalized)

      normalized.scan(SVG_CSS_URL_VALUE).any? { |groups| forbidden_reference_value?(groups.compact.first) }
    end

    # Removes the comments and the strings of a style sheet, which are not
    # interpreted as directives when the style sheet is rendered, so that text
    # which only looks like a reference (e.g. 'content: "See @import"') is not
    # mistaken for one. The strings which define the URL of a function which
    # loads its arguments are kept, as those URLs are loaded. Comments and
    # strings are detected following the tokenization rules of CSS, in which
    # comments are not recognized inside strings and escape sequences hide the
    # character following them, so that neither can be used to hide a reference
    # (e.g. 'content: "/*"; background: url(https://example.org)'). The reference
    # of a function is kept after a comment as well, as some engines tokenize the
    # comment inside the function instead of reading it as part of the URL.
    def scrub_css(css)
      scanner = StringScanner.new(css)
      output = +""
      url_functions = []
      until scanner.eos?
        if scanner.scan(%r{/\*})
          scan_css_comment(scanner)
        elsif (quote = scanner.scan(/["']/))
          # The string token is always consumed, as its content is not
          # interpreted as CSS. Only the strings of the functions which load
          # their arguments define a loaded URL.
          string = scan_css_string(scanner, quote)
          output << string if url_functions.any?
        elsif (ident = scan_css_ident(scanner))
          output << ident
          if scanner.match?(/\(/)
            url_functions.push(css_url_function?(ident))
            output << scanner.getch
          end
        else
          char = scanner.getch
          output << char
          # The arguments of these functions are kept until the function ends,
          # as "image-set()" can declare several URLs. The opening parentheses
          # which do not follow an identifier are tracked as well, so that their
          # closing ones do not end an enclosing function and drop its arguments.
          url_functions.push(false) if char == "("
          url_functions.pop if char == ")"
        end
      end
      output
    end

    # Consumes the comment token of CSS which starts at the current position.
    # Unterminated comments extend to the end of the style sheet.
    def scan_css_comment(scanner)
      scanner.scan_until(%r{\*/}) || (scanner.pos = scanner.string.length)
    end

    # Consumes the string token of CSS which starts at the given quote, and
    # returns it with its quotes. Escape sequences hide the following
    # character, and an unescaped newline or the end of the input end the
    # token, as in the tokenization rules of CSS.
    def scan_css_string(scanner, quote)
      token = quote.dup
      until scanner.eos?
        escape = scanner.scan(CSS_ESCAPE)
        if escape
          token << escape
        elsif scanner.match?(quote)
          token << scanner.getch
          break
        elsif scanner.match?(/[\n\r\f]/)
          break
        else
          token << scanner.getch
        end
      end
      token
    end

    # Consumes the identifier token of CSS which starts at the current
    # position, including its escape sequences, and returns it as it is
    # written. Returns nil when no identifier starts at the current position.
    # An identifier starts with a letter, an underscore, a non-ASCII character,
    # an escape sequence, or a hyphen followed by one of those, and continues
    # with any of those or a digit: digits are only accepted after the first
    # character, as "5url(" is a number followed by a function while "url5(" is
    # another function.
    def scan_css_ident(scanner)
      prefix = scanner.scan(/-?(?:[a-zA-Z_]|[^\x00-\x7f])/) || (scanner.match?(CSS_ESCAPE) && "")
      return nil if prefix.nil?

      ident = prefix.dup
      loop do
        char = scanner.scan(CSS_ESCAPE) || scanner.scan(/[-\w]|[^\x00-\x7f]/)
        break if char.nil?

        ident << char
      end
      ident
    end

    # Whether the identifier is the name of a function which loads its arguments
    # as resources. The name is matched after decoding its escape sequences, as
    # they are processed before the name is interpreted, so that functions
    # written with escapes (e.g. "u\72l(...)") are also recognized.
    def css_url_function?(ident)
      CSS_URL_FUNCTIONS.any? { |name| decode_css_escapes(ident).casecmp?(name) }
    end

    # Decodes the escape sequences of CSS. Invalid codepoints are replaced with
    # the replacement character.
    def decode_css_escapes(css)
      css.gsub(CSS_ESCAPE) do
        digits = Regexp.last_match[:hex]
        next Regexp.last_match[:char] if digits.nil?

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
  end
end

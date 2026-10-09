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
  # "image", "use" and "feImage", the style sheets and the "xml-stylesheet"
  # instruction) are restricted to the document itself and to inline data, so
  # that documents cannot make the browser of the reader fetch third-party
  # resources. Links ("a") are not restricted, as they do not load any
  # resource when the document is rendered.
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
    # attributes are validated as element/attribute names.
    SVG_ANIMATION_TARGET_NAMES = %w(attribute attributeName attributeNames).freeze

    # The elements which load the resource referenced by their "href" (or
    # legacy "xlink:href") attribute into the document when it is rendered.
    # The references of these elements are restricted to the document itself
    # and to inline data, as absolute references make the browser of the
    # reader fetch resources from third-party hosts, which can be used for
    # tracking or for probing internal networks. Links ("a") are not
    # included, as they do not load any resource.
    SVG_RESOURCE_ELEMENTS = %w(image use feimage).freeze

    # The name of the attribute which references the resource loaded by an
    # element, either "href" or the legacy "xlink:href", which is also
    # matched with an undeclared prefix, as browsers resolve it as the XLink
    # reference.
    SVG_REFERENCE_NAME = /\A(?:[\w.-]+:)?href\z/i

    # The references which load a resource from another host: URIs with a
    # scheme (e.g. "https:") and protocol-relative references (e.g.
    # "//example.org"). Fragment ("#") and relative references are resolved
    # against the document itself, and "data:image/" references are inline,
    # so they are accepted.
    SVG_EXTERNAL_REFERENCE = %r{\A(?!data:image/)(?:[a-z][a-z0-9+.-]*:|//)}i

    # The elements which modify the attributes of another element at runtime.
    # When they target a reference attribute of an element which loads the
    # referenced resource, the values assigned to it are validated as
    # references, as the resource is loaded when the animation reaches it.
    SVG_ANIMATION_ELEMENTS = %w(animate set).freeze
    SVG_ANIMATION_VALUE_NAMES = %w(values from to by).freeze

    # The CSS at-rules and functions which load external resources when the
    # style sheets of an SVG document are rendered. Imports always fetch a
    # resource, and URL references with a scheme (e.g. "https:") or a
    # protocol-relative host (e.g. "//example.org") fetch one from another
    # host, so documents containing them are rejected. Fragment ("#") and
    # relative references are resolved against the document itself, and
    # "data:" references are inline, so they are accepted.
    SVG_CSS_IMPORT = /@import/i
    SVG_CSS_EXTERNAL_URL = %r{url\(\s*["']?\s*(?!data:)(?:[a-z][a-z0-9+.-]*:|//)}i

    # The escape sequences of CSS, which consist of a backslash followed by up
    # to six hexadecimal digits, with an optional whitespace terminating the
    # sequence, or by any other character.
    CSS_ESCAPE = /\\(?:(?<hex>\h{1,6})[ \t\n\r\f]?|(?<char>.))/m

    # The declaration of entities in the document type definition of an SVG
    # document. Entities can be used to read external resources (XXE) or to
    # expand content exponentially (billion laughs), so documents declaring them
    # are rejected. External DTD references without entity declarations are
    # accepted, as the DTDs are never fetched (see #parse).
    SVG_ENTITY_DECLARATION = /<!ENTITY/i

    # Validates the contents of an SVG document. Returns :valid when the
    # document can be stored, :invalid when the contents are not a well formed
    # SVG document, and :unsafe when the document contains content which could
    # execute scripts or read external resources when it is rendered.
    def self.validate(content)
      new(content).validate
    end

    def initialize(content)
      @content = content
    end

    def validate
      return :invalid if content.blank?
      return :unsafe if SVG_ENTITY_DECLARATION.match?(content)

      document = parse
      return :invalid if document.nil?
      return :unsafe if forbidden_content?(document)

      :valid
    end

    private

    attr_reader :content

    # Parses the SVG document without fetching any external resource (e.g. an
    # external DTD) and without substituting entities, so that a malicious
    # document cannot make the server read external resources or expand entities
    # while it is validated. Returns nil when the contents are not a well formed
    # XML document with an "svg" root element.
    def parse
      document = Nokogiri::XML.parse(content, &:nonet)
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
      return true if attribute.name.downcase == "style" && forbidden_css_content?(attribute.value.to_s)
      return true if SVG_ANIMATION_TARGET_NAMES.include?(attribute.name) && forbidden_name?(attribute.value.to_s)

      forbidden_resource_reference?(node, attribute)
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
    # are never fetched when the document is rendered.
    def forbidden_animation_reference?(node)
      return false unless SVG_ANIMATION_ELEMENTS.include?(node.name.downcase)

      target = node["attributeName"] || node["attribute"]
      return false unless SVG_REFERENCE_NAME.match?(target.to_s)
      return false unless animates_resource_element?(node)

      SVG_ANIMATION_VALUE_NAMES.any? do |name|
        node[name].to_s.split(";").any? { |value| forbidden_reference_value?(value) }
      end
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
    # identifier of the fragment. References to other documents or to missing
    # identifiers do not resolve to any element.
    def referenced_elements(document, reference)
      id = reference[/\A#(.*)\z/m, 1]
      return [] if id.nil?

      document.xpath("//*[@id = $id]", nil, { "id" => id })
    end

    # Whether the element loads the resource referenced by its reference
    # attribute when the document is rendered.
    def resource_element?(element)
      SVG_RESOURCE_ELEMENTS.include?(element.name.downcase)
    end

    # Whether the reference loads a resource from another host. The whitespace
    # and control characters which can be used to obfuscate the scheme are
    # removed before checking.
    def forbidden_reference_value?(value)
      SVG_EXTERNAL_REFERENCE.match?(normalize_uri_value(value))
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

    # Whether the CSS of a "style" element or attribute loads external
    # resources when the document is rendered. The comments and the strings
    # which do not define a URL are removed, and the escape sequences decoded,
    # before checking, as they can otherwise hide the references (e.g.
    # "u\rl(https://example.org)") or be mistaken for them (e.g. 'content:
    # "See @import instructions"').
    def forbidden_css_content?(css)
      normalized = decode_css_escapes(scrub_css(css))
      SVG_CSS_IMPORT.match?(normalized) || SVG_CSS_EXTERNAL_URL.match?(normalized)
    end

    # Removes the comments and the strings of a style sheet, which are not
    # interpreted as directives when the style sheet is rendered, so that text
    # which only looks like a reference (e.g. 'content: "See @import"') is not
    # mistaken for one. The strings which define the URL of a "url()" function
    # are kept, as those URLs are loaded. Comments and strings are detected
    # following the tokenization rules of CSS, in which comments are not
    # recognized inside strings and escape sequences hide the character
    # following them, so that neither can be used to hide a reference (e.g.
    # 'content: "/*"; background: url(https://example.org)').
    def scrub_css(css)
      scanner = StringScanner.new(css)
      output = +""
      in_url = false
      until scanner.eos?
        if scanner.scan(%r{/\*})
          # Unterminated comments extend to the end of the style sheet.
          scanner.scan_until(%r{\*/}) || (scanner.pos = scanner.string.length)
          in_url = false
        elsif (quote = scanner.scan(/["']/))
          string = scan_css_string(scanner, quote)
          # Only the strings immediately following a "url()" function define a
          # loaded URL.
          output << string if in_url
          in_url = false
        elsif (ident = scan_css_ident(scanner))
          url = css_url_function?(scanner, ident)
          output << ident
          output << scanner.getch if url
          in_url = url
        elsif (whitespace = scanner.scan(/\s+/))
          output << whitespace
        else
          output << scanner.getch
          in_url = false
        end
      end
      output
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

    # Whether the identifier consumed just before the current position, when
    # followed by an opening parenthesis, is the name of a "url()" function. The
    # name is matched after decoding its escape sequences, as they are processed
    # before the name is interpreted, so that functions written with escapes
    # (e.g. "u\72l(...)") are also recognized.
    def css_url_function?(scanner, ident)
      scanner.match?(/\(/) && decode_css_escapes(ident).casecmp?("url")
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

# frozen_string_literal: true

require "doc2text"
require "tempfile"

module Decidim
  module Proposals
    # This class parses a participatory text document in markdown and
    # produces Proposals in the form of sections and articles.
    #
    # This implementation uses Redcarpet Base renderer.
    # Redcarpet::Render::Base performs a callback for every block it finds, what MarkdownToProposals
    # does is to implement callbacks for the blocks which it is interested in performing some actions.
    #
    class DocToMarkdown
      MARKDOWN_MIME_TYPE = "text/markdown"
      ODT_MIME_TYPE = "application/vnd.oasis.opendocument.text"
      DOCX_MIME_TYPE = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"

      # Public: Initializes the serializer with a proposal.
      def initialize(doc, mime_type)
        @doc = doc
        @transformer = case mime_type
                       # when MARKDOWN_MIME_TYPE
                       # no transformer required
                       when ODT_MIME_TYPE
                         # convert libreoffice odt to markdown
                         OdtToMarkdown.new(doc)
                       when DOCX_MIME_TYPE
                         # convert word 2013 docx to markdown
                         DocxToMarkdown.new(doc)
                       end
      end

      def to_md
        @transformer ? @transformer.to_md : @doc
      end
    end
  end
end

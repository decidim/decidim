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
    class OdtToMarkdown
      # Public: Initializes the serializer with a proposal.
      def initialize(doc)
        @doc = doc
      end

      def to_md
        doc_file = doc_to_tmp_file
        md_file = transform_to_md_file(doc_file)
        md_file.read
      end

      #-----------------------------------------------------

      private

      #-----------------------------------------------------

      def doc_to_tmp_file
        file = Tempfile.new("doc-to-markdown-odt", encoding: "ascii-8bit")
        file.write(@doc)
        file
      end

      def transform_to_md_file(doc_file)
        md_file = Tempfile.new
        Doc2Text::Odt::Document.parse_and_save doc_file, md_file
        md_file
      end
    end
  end
end

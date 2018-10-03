# frozen_string_literal: true
require 'redcarpet'

module Decidim
  module Proposals
    # This class parses a participatory text document in markdown and
    # produces Proposalsin the form of sections and articles
    class Markdown2Proposals < ::Redcarpet::Render::Base

      # Public: Initializes the serializer with a proposal.
      def initialize(component)
        super()
        @component = component
        @last_position = 0
      end

      def parse(document)
        puts "docIS: #{document}\n---------------------"
        renderer= self
        parser = ::Redcarpet::Markdown.new(renderer)
        str= parser.render(document)
        puts "document PARSED.: #{str}"
        str
      end

      ##########################################
      # Redcarpet callbacks
      ##########################################

      def preprocess(full_document)
        full_document
      end
      def postprocess(full_document)
        full_document
      end

      def doc_header
      end
      def doc_footer
      end

      # def normal_text(text)
      #   puts "normal_text: #{text}"
      #    text
      # end

      # def block_code(code, language)
      #   puts "block_code #{code}[#{language}]"
      #    "block_code #{code}[#{language}]"
      # end

      # def codespan(code)
      #   puts "codespan #{code}"
      #    "codespan #{code}"
      # end

      def header(title, level)
        puts "header #{title} / #{level}"

        pt_level= level > 1 ?
          Decidim::Proposals::Proposal::PARTICIPATORY_TEXT_LEVEL[:sub_section] :
          Decidim::Proposals::Proposal::PARTICIPATORY_TEXT_LEVEL[:section]
        proposal= Decidim::Proposals::Proposal.create!(
          component: @component,
          title: title,
          body: title,
          participatory_text_level: pt_level
        )
        @last_position = proposal.position
        title
      end

      def paragraph(text)
        proposal= Decidim::Proposals::Proposal.create!(
          component: @component,
          title: (@last_position+1).to_s,
          body: text,
          participatory_text_level: Decidim::Proposals::Proposal::PARTICIPATORY_TEXT_LEVEL[:article]
        )
        @last_position = proposal.position
        text
      end

      # def list(content, list_type)
      #   txt= case list_type
      #   when :ordered
      #     "\n\n.nr step 0 1\n#{content}\n"
      #   when :unordered
      #     "\n\n#{content}\n"
      #   end
      #   puts txt
      #   # @doc_part.add(DocPart.new(:list, @doc_part.level, txt, @doc_part))
      #   txt
      # end

      # def list_item(content, list_type)
        # puts "list_item(#{content}, #{list_type})"
        # txt= case list_type
        # when :ordered
        #   "\n\nnum. step 0 1\n#{content}\n"
        # when :unordered
        #   "\n\n- #{content}\n"
        # end
        # @doc_part.add(DocPart.new(:list_item, @doc_part.level, txt, @doc_part))
        # content
      # end
    end
  end
end

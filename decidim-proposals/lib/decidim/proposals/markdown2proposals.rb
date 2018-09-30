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
      end

      def parse(document)
        puts "docIS: #{document}\n---------------------"
        renderer= self
        # require 'redcarpet/render_man'
        # renderer= Redcarpet::Render::ManPage
        parser = ::Redcarpet::Markdown.new(renderer)
        str= parser.render(document)
        puts "document PARSED.: #{str}"
        str
      end

      ##########################################
      # Redcarpet callbacks
      ##########################################

      def preprocess(full_document)
        puts "DOC PREPROC"
        full_document
      end
      def postprocess(full_document)
        puts "DOC POSTPROC"
        full_document
      end

      def doc_header
        puts "DOC HEADER"
      end
      def doc_footer
        puts "DOC FOOTER"
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

        Decidim::Proposals::Proposal.create!(
          component: @component,
          title: title,
          body: title
          )
        # if level == 1
        #   parent= @doc_part
        #   @doc_part= DocPart.new(:header, level, title, parent)
        #   parent.add(@doc_part)
        # else #same level
        #   parent= @doc_part.parent
        #   @doc_part= DocPart.new(:header, level, title, parent)
        #   parent.add(@doc_part)
        # end
         "header #{title} / #{level}"
      end

      # # def double_emphasis(text)
      # #   puts "double_emphasis #{double_emphasis}"
      # #   "double_emphasis #{double_emphasis}"
      # # end

      # # def emphasis(text)
      # #   puts "emphasis #{text}"
      # #   "emphasis #{text}"
      # # end

      # def linebreak
      #   puts "linebreak\n"
      #   "linebreak\n"
      # end

      def paragraph(text)
        puts "paragraph (#{text})"
        Decidim::Proposals::Proposal.create!(
          component: @component,
          title: title,
          body: text
          )
        # @doc_part.add(DocPart.new(:paragraph, @doc_part.level, text, @doc_part))
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

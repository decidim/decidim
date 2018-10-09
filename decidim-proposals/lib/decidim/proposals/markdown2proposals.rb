# frozen_string_literal: true

require "redcarpet"

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
        @num_sections = 0
      end

      def parse(document)
        renderer = self
        parser = ::Redcarpet::Markdown.new(renderer)
        parser.render(document)
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

      def doc_header; end

      def doc_footer; end

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
        pt_level = if level > 1
                     Decidim::Proposals::ParticipatoryTextSection::LEVELS[:sub_section]
                   else
                     Decidim::Proposals::ParticipatoryTextSection::LEVELS[:section]
                   end

        proposal = Decidim::Proposals::Proposal.create!(
          component: @component,
          title: title,
          body: title,
          participatory_text_level: pt_level
        )
        @last_position = proposal.position
        @num_sections += 1
        title
      end

      def paragraph(text)
        return if text.blank?

        proposal = Decidim::Proposals::Proposal.create!(
          component: @component,
          title: (@last_position + 1 - @num_sections).to_s,
          body: text,
          participatory_text_level: Decidim::Proposals::ParticipatoryTextSection::LEVELS[:article]
        )
        @last_position = proposal.position
        text
      end

      # ignore images
      def image(link, title, alt_text)
        ""
      end

      # def link(_link, _title, _content)
      #   "link!!!"
      # end

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

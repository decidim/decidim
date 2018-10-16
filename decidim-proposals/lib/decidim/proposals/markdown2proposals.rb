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

      # Recarpet callback to process headers.
      # Creates Paricipatory Text Proposals at Section and Subsection levels.
      def header(title, level)
        participatory_text_level = if level > 1
                     Decidim::Proposals::ParticipatoryTextSection::LEVELS[:sub_section]
                   else
                     Decidim::Proposals::ParticipatoryTextSection::LEVELS[:section]
                   end

        proposal = Decidim::Proposals::Proposal.create!(
          component: @component,
          title: title,
          body: title,
          participatory_text_level: participatory_text_level
        )
        @last_position = proposal.position
        @num_sections += 1
        title
      end

      # Recarpet callback to process paragraphs.
      # Creates Paricipatory Text Proposals at Article level.
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

    end
  end
end

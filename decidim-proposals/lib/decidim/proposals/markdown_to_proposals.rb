# frozen_string_literal: true

require "redcarpet"

module Decidim
  module Proposals
    # This class parses a participatory text document in markdown and
    # produces Proposals in the form of sections and articles.
    #
    # This implementation uses Redcarpet Base renderer.
    # Redcarpet::Render::Base performs a callback for every block it finds, what MarkdownToProposals
    # does is to implement callbacks for the blocks which it is interested in performing some actions.
    #
    class MarkdownToProposals < ::Redcarpet::Render::Base
      # Public: Initializes the serializer with a proposal.
      def initialize(component, current_user)
        super()
        @component = component
        @current_user = current_user
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

        create_proposal(title, title, participatory_text_level)

        @num_sections += 1
        title
      end

      # Recarpet callback to process paragraphs.
      # Creates Paricipatory Text Proposals at Article level.
      def paragraph(text)
        return if text.blank?

        create_proposal(
          (@last_position + 1 - @num_sections).to_s,
          text,
          Decidim::Proposals::ParticipatoryTextSection::LEVELS[:article]
        )

        text
      end

      def link(link, title, content)
        attrs = %(href="#{link}")
        attrs += %( title="#{title}") if title.present?
        "<a #{attrs}>#{content}</a>"
      end

      def image(link, title, alt_text)
        attrs = %(src="#{link}")
        attrs += %( alt="#{alt_text}") if alt_text.present?
        attrs += %( title="#{title}") if title.present?
        "<img #{attrs}/>"
      end

      private

      def create_proposal(title, body, participatory_text_level)
        attributes = {
          component: @component,
          title: title,
          body: body,
          participatory_text_level: participatory_text_level
        }

        proposal = Decidim::Proposals::ProposalBuilder.create(
          attributes: attributes,
          author: @component.organization,
          action_user: @current_user
        )

        @last_position = proposal.position

        proposal
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Proposals
    # Simple helper to handle markup variations for participatory texts related partials
    module ParticipatoryTextsHelper
      # Returns the title for a given participatory text section.
      #
      # proposal - The current proposal item.
      #
      # Returns a string with the title of the section, subsection or article.
      def preview_participatory_text_section_title(proposal)
        translated = t(proposal.participatory_text_level, scope: "decidim.proposals.admin.participatory_texts.sections", title: proposal.title)
        translated.html_safe
      end

      def render_participatory_text_title(participatory_text)
        if participatory_text.nil?
          t("alternative_title", scope: "decidim.proposals.participatory_text_proposal")
        else
          translated_attribute(participatory_text.title)
        end
      end
    end
  end
end

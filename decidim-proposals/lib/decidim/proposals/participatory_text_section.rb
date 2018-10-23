# frozen_string_literal: true

module Decidim
  module Proposals
    # The data store for a Proposal in the Decidim::Proposals component.
    module ParticipatoryTextSection
      extend ActiveSupport::Concern

      LEVELS = {
        section: "section", sub_section: "sub-section", article: "article"
      }.freeze

      included do
        # Public: is this section an :article?
        def article?
          participatory_text_level == LEVELS[:article]
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Initiatives
    # This cell renders the assembly metadata for g card
    class InitiativeMetadataGCell < Decidim::CardMetadataCell
      include Cell::ViewModel::Partial
      include Decidim::Initiatives::InitiativeHelper

      alias current_initiative resource
      alias initiative resource
      def items
        [""]
      end
    end
  end
end

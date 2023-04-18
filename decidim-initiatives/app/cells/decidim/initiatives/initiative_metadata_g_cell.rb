# frozen_string_literal: true

module Decidim
  module Initiatives
    # This cell renders the assembly metadata for g card
    class InitiativeMetadataGCell < Decidim::CardMetadataCell
      include Cell::ViewModel::Partial

      alias current_initiative resource
      alias initiative resource

      def items
        ["test"]
      end
    end
  end
end

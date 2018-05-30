# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the tags for a proposal.
    class ProposalTagsCell < Decidim::ViewModel
      include ProposalCellsHelper

      property :category
      property :previous_category
      property :scope

      private

      def show_previous_category?
        options[:show_previous_category].to_s != "false"
      end
    end
  end
end

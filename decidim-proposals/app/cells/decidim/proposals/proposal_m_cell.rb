# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders a proposal with its M-size card.
    class ProposalMCell < Decidim::Proposals::ProposalCell
      include Cell::ViewModel::Partial

      def show
        render
      end

      def footer
        render
      end

      def header
        render
      end

      def badge
        render
      end

      private

      def resource_path
        resource_locator(model).path
      end

      def body
        truncate(model.body, length: 100)
      end
    end
  end
end

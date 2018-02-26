# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalCell < Decidim::ResultCell
      include LayoutHelper

      def show
        render
      end

      private

      def title
        model.title
      end

    end
  end
end

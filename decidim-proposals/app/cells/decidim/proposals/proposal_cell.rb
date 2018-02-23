# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalCell < Decidim::ViewModel
      include LayoutHelper

      def show
        render
      end

      private

      def title
        model.title
      end

      def proposal_path
        resource_locator(model).path
      end
    end
  end
end

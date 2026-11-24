# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe OpenDataProposalSerializer do
      subject do
        described_class.new(proposal)
      end

      include_context "with a proposal"

      it_behaves_like "a proposal serializer"

      it_behaves_like "a proposal serializer with author"
    end
  end
end

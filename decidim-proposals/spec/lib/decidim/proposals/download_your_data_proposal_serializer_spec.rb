# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe DownloadYourDataProposalSerializer do
      subject do
        described_class.new(proposal)
      end

      include_context "with a proposal"

      it_behaves_like "a proposal serializer"
    end
  end
end

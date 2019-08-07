# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalEndorsementsHelper do
      describe "Show endorsements card" do
        subject { helper.show_endorsements_card? }

        before do
          allow(helper).to receive(:current_settings).and_return(double(endorsements_enabled: endorsements_enabled))
        end

        context "when endorsements are enabled" do
          let(:endorsements_enabled) { true }

          it { is_expected.to be true }
        end

        context "when endorsements are NOT enabled" do
          let(:endorsements_enabled) { false }

          it { is_expected.to be false }
        end
      end
    end
  end
end

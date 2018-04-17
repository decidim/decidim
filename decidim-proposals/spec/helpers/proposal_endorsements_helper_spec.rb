# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalEndorsementsHelper do
      let!(:organization) { create(:organization) }
      let!(:component) { create(:component, organization: organization, manifest_name: "proposals") }
      let!(:participatory_process) { create(:participatory_process, organization: organization) }
      let!(:author) { create(:user, organization: organization) }
      let!(:user_group) { create(:user_group, verified_at: DateTime.current) }
      let!(:proposal) { create(:proposal, component: component, author: author) }

      describe "Identity of an endorsement" do
        context "when the endorsement belongs to a user" do
          let!(:endorsement) do
            build(:proposal_endorsement, proposal: proposal, author: author)
          end

          it "returns the user author of the endorsement" do
            expect(helper.endorsement_identity(endorsement)).to eq author
          end
        end
        context "when the endorsement belongs to a user_group" do
          let!(:endorsement) do
            build(:proposal_endorsement, proposal: proposal, author: author,
                                         user_group: user_group)
          end

          it "returns the user_group that endorsed" do
            expect(helper.endorsement_identity(endorsement)).to eq user_group
          end
        end
      end

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

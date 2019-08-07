# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalEndorsement do
      subject { proposal_endorsement }

      let!(:organization) { create(:organization) }
      let!(:component) { create(:component, organization: organization, manifest_name: "proposals") }
      let!(:participatory_process) { create(:participatory_process, organization: organization) }
      let!(:author) { create(:user, organization: organization) }
      let!(:user_group) { create(:user_group, verified_at: Time.current, organization: organization, users: [author]) }
      let!(:proposal) { create(:proposal, component: component, users: [author]) }
      let!(:proposal_endorsement) do
        build(:proposal_endorsement, proposal: proposal, author: author,
                                     user_group: user_group)
      end

      it "is valid" do
        expect(proposal_endorsement).to be_valid
      end

      it "has an associated author" do
        expect(proposal_endorsement.author).to be_a(Decidim::User)
      end

      it "has an associated proposal" do
        expect(proposal_endorsement.proposal).to be_a(Decidim::Proposals::Proposal)
      end

      it "validates uniqueness for author and user_group and proposal combination" do
        proposal_endorsement.save!
        expect do
          create(:proposal_endorsement, proposal: proposal, author: author,
                                        user_group: user_group)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end

      context "when no author" do
        before do
          proposal_endorsement.author = nil
        end

        it { is_expected.to be_invalid }
      end

      context "when no user_group" do
        before do
          proposal_endorsement.user_group = nil
        end

        it { is_expected.to be_valid }
      end

      context "when no proposal" do
        before do
          proposal_endorsement.proposal = nil
        end

        it { is_expected.to be_invalid }
      end

      context "when proposal and author have different organization" do
        let(:other_author) { create(:user) }
        let(:other_proposal) { create(:proposal) }

        it "is invalid" do
          proposal_endorsement = build(:proposal_endorsement, proposal: other_proposal, author: other_author)
          expect(proposal_endorsement).to be_invalid
        end
      end

      context "when proposal is rejected" do
        let!(:proposal) { create(:proposal, :rejected, component: component, users: [author]) }

        it { is_expected.to be_invalid }
      end

      context "when retrieving for_listing" do
        before do
          proposal_endorsement.save!
        end

        let!(:other_user_group) { create(:user_group, verified_at: Time.current, organization: author.organization, users: [author]) }
        let!(:other_proposal_endorsement_1) do
          create(:proposal_endorsement, proposal: proposal, author: author)
        end
        let!(:other_proposal_endorsement_2) do
          create(:proposal_endorsement, proposal: proposal, author: author, user_group: other_user_group)
        end

        it "sorts user_grup endorsements first and then by created_at" do
          expected_sorting = [
            proposal_endorsement.id, other_proposal_endorsement_2.id,
            other_proposal_endorsement_1.id
          ]
          expect(proposal.endorsements.for_listing.pluck(:id)).to eq(expected_sorting)
        end
      end
    end
  end
end

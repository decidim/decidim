# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Engine do
  it_behaves_like "clean engine"

  describe "decidim_proposals.remove_space_admins" do
    let(:component) { create(:proposal_component, participatory_space: space) }
    let(:valuator) { create(:user, organization:) }
    let(:proposal) { create(:proposal, component:) }

    context "when removing participatory_space admin" do
      let(:space) { valuator_role.participatory_process }
      let(:valuator_role) { create(:participatory_process_user_role) }
      let!(:assignment) { create(:valuation_assignment, proposal:, valuator_role:) }

      it "removes the record" do
        expect do
          ActiveSupport::Notifications.publish("decidim.admin.participatorty_space.destroy_admin:after", valuator_role.class.name, valuator_role.id)
        end.to change(Decidim::Proposals::ValuationAssignment, :count).by(-1)
      end
    end

    context "when removing assembly admin" do
      let(:space) { valuator_role.assembly }
      let(:valuator_role) { create(:assembly_user_role) }
      let!(:assignment) { create(:valuation_assignment, proposal:, valuator_role:) }

      it "removes the record" do
        expect do
          ActiveSupport::Notifications.publish("decidim.admin.participatorty_space.destroy_admin:after", valuator_role.class.name, valuator_role.id)
        end.to change(Decidim::Proposals::ValuationAssignment, :count).by(-1)
      end
    end

    context "when removing conference admin" do
      let(:space) { valuator_role.conference }
      let(:valuator_role) { create(:conference_user_role) }
      let!(:assignment) { create(:valuation_assignment, proposal:, valuator_role:) }

      it "removes the record" do
        expect do
          ActiveSupport::Notifications.publish("decidim.admin.participatorty_space.destroy_admin:after", valuator_role.class.name, valuator_role.id)
        end.to change(Decidim::Proposals::ValuationAssignment, :count).by(-1)
      end
    end
  end

  describe "decidim_proposals.authorization_transfer" do
    include_context "authorization transfer"

    let(:component) { create(:proposal_component, :with_votes_enabled, organization:) }
    let(:proposal1) { create(:proposal, component:) }
    let(:proposal2) { create(:proposal, component:) }
    let(:proposal3) { create(:proposal, component:) }
    let(:original_records) do
      {
        votes: [
          create(:proposal_vote, proposal: proposal1, author: original_user),
          create(:proposal_vote, proposal: proposal2, author: original_user),
          create(:proposal_vote, proposal: proposal3, author: original_user)
        ]
      }
    end
    let(:transferred_votes) { Decidim::Proposals::ProposalVote.where(author: target_user).order(:id) }

    it "handles authorization transfer correctly" do
      expect(transferred_votes.count).to eq(3)
      expect(transfer.records.count).to eq(3)
      expect(transferred_resources).to eq(transferred_votes)
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Engine do
  it_behaves_like "clean engine"

  describe "decidim_proposals.remove_space_admins" do
    let(:component) { create(:proposal_component, participatory_space: space) }
    let(:evaluator) { create(:user, organization:) }
    let(:proposal) { create(:proposal, component:) }

    context "when removing participatory_space admin" do
      let(:space) { evaluator_role.participatory_process }
      let(:evaluator_role) { create(:participatory_process_user_role) }
      let!(:assignment) { create(:evaluation_assignment, proposal:, evaluator_role:) }

      it "removes the record" do
        expect do
          ActiveSupport::Notifications.publish("decidim.admin.participatory_space.destroy_admin:after", class_name: evaluator_role.class.name, role: evaluator_role.id)
        end.to change(Decidim::Proposals::EvaluationAssignment, :count).by(-1)
      end
    end

    context "when removing assembly admin" do
      let(:space) { evaluator_role.assembly }
      let(:evaluator_role) { create(:assembly_user_role) }
      let!(:assignment) { create(:evaluation_assignment, proposal:, evaluator_role:) }

      it "removes the record" do
        expect do
          ActiveSupport::Notifications.publish("decidim.admin.participatory_space.destroy_admin:after", class_name: evaluator_role.class.name, role: evaluator_role.id)
        end.to change(Decidim::Proposals::EvaluationAssignment, :count).by(-1)
      end
    end

    context "when removing conference admin" do
      let(:space) { evaluator_role.conference }
      let(:evaluator_role) { create(:conference_user_role) }
      let!(:assignment) { create(:evaluation_assignment, proposal:, evaluator_role:) }

      it "removes the record" do
        expect do
          ActiveSupport::Notifications.publish("decidim.admin.participatory_space.destroy_admin:after", class_name: evaluator_role.class.name, role: evaluator_role.id)
        end.to change(Decidim::Proposals::EvaluationAssignment, :count).by(-1)
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

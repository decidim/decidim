# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe UnassignProposalsFromValuator do
        describe "call" do
          let!(:assigned_proposal) { create(:proposal, component: current_component) }
          let!(:unassigned_proposal) { create(:proposal, component: current_component) }
          let!(:current_component) { create(:proposal_component) }
          let(:space) { current_component.participatory_space }
          let(:organization) { space.organization }
          let(:user) { create :user, organization: }
          let(:valuator) { create :user, organization: }
          let(:valuator_role) { create :participatory_process_user_role, role: :valuator, user: valuator, participatory_process: space }
          let!(:assignment) { create :valuation_assignment, proposal: assigned_proposal, valuator_role: }
          let(:form) do
            instance_double(
              ValuationAssignmentForm,
              current_user: user,
              current_component:,
              current_organization: current_component.organization,
              valuator_role:,
              proposals: [assigned_proposal, unassigned_proposal],
              valid?: valid
            )
          end
          let(:command) { described_class.new(form) }

          describe "when the form is not valid" do
            let(:valid) { false }

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "doesn't destroy the assignments" do
              expect do
                command.call
              end.not_to change(ValuationAssignment, :count)
            end
          end

          describe "when the form is valid" do
            let(:valid) { true }

            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "destroys the valuation assignment between the user and the proposal" do
              expect do
                command.call
              end.to change { ValuationAssignment.where(valuator_role:).count }.from(1).to(0)
            end

            it "traces the action", versioning: true do
              expect(Decidim.traceability)
                .to receive(:perform_action!)
                .with(:delete, assignment, form.current_user, proposal_title: assigned_proposal.title)
                .and_call_original

              expect { command.call }.to change(Decidim::ActionLog, :count)
              action_log = Decidim::ActionLog.last
              expect(action_log.version).to be_present
              expect(action_log.version.event).to eq "destroy"
            end
          end
        end
      end
    end
  end
end

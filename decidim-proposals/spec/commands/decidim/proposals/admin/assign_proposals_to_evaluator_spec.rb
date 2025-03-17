# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe AssignProposalsToEvaluator do
        describe "call" do
          let!(:proposal) { create(:proposal, component: current_component) }
          let!(:current_component) { create(:proposal_component) }
          let(:space) { current_component.participatory_space }
          let(:organization) { space.organization }
          let(:user) { create(:user, organization:) }
          let(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user:, participatory_process: space) }
          let(:evaluator_roles) { [evaluator_role] }
          let(:form) do
            instance_double(
              EvaluationAssignmentForm,
              current_user: user,
              current_component:,
              current_organization: current_component.organization,
              evaluator_roles:,
              proposals: [proposal],
              valid?: valid
            )
          end
          let(:command) { described_class.new(form) }

          describe "when the form is not valid" do
            let(:valid) { false }

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "does not create the assignments" do
              expect do
                command.call
              end.not_to change(EvaluationAssignment, :count)
            end
          end

          describe "when the form is valid" do
            let(:valid) { true }

            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "creates the evaluation assignment between the user and the proposal" do
              expect do
                command.call
              end.to change { EvaluationAssignment.where(proposal:, evaluator_role:).count }.by(1)
            end

            it "traces the action", versioning: true do
              expect(Decidim.traceability)
                .to receive(:create!)
                .with(Decidim::Proposals::EvaluationAssignment, form.current_user, proposal:, evaluator_role:)
                .and_call_original

              expect { command.call }.to change(Decidim::ActionLog, :count)
              action_log = Decidim::ActionLog.last
              expect(action_log.version).to be_present
              expect(action_log.version.event).to eq "create"
            end

            context "when it raises an error while creating assignments" do
              before do
                allow(Decidim::Proposals::EvaluationAssignment).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
              end

              it "broadcasts invalid" do
                expect { command.call }.to broadcast(:invalid)
              end

              it "does not create any assignment" do
                expect { command.call }.not_to change(EvaluationAssignment, :count)
              end
            end
          end
        end
      end
    end
  end
end

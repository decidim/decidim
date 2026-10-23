# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::DestroyParticipatoryProcessPhase, class: true do
    subject { described_class.new(phase, user) }

    let!(:participatory_process) { create(:participatory_process) }
    let!(:user) { create(:user, :admin, :confirmed) }

    let!(:active_phase) do
      create(:participatory_process_phase, participatory_process:, active: true)
    end
    let(:phase) { active_phase }

    context "when there is more than one phase" do
      let!(:inactive_phase) do
        create(:participatory_process_phase, participatory_process:, active: false)
      end

      context "when deleting the active phase" do
        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end

        it "does not delete the phase" do
          subject.call
          expect(active_phase).to be_persisted
        end
      end

      context "when deleting an inactive phase" do
        let(:reorderer) { double(call: true) }
        let(:phase) { inactive_phase }

        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "delete the phase" do
          subject.call
          expect { inactive_phase.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(:delete, inactive_phase, user)
            .and_call_original

          expect { subject.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
          expect(action_log.version.event).to eq "destroy"
        end

        it "reorders the remaining phases" do
          allow(Admin::ReorderParticipatoryProcessPhases)
            .to receive(:new)
            .with([active_phase], [active_phase.id])
            .and_return(reorderer)
          expect(reorderer).to receive(:call)

          subject.call
        end
      end
    end

    context "when trying to delete the last phase" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end
    end
  end
end

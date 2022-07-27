# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::DestroyParticipatoryProcessStep, class: true do
    subject { described_class.new(step, user) }

    let!(:participatory_process) { create(:participatory_process) }
    let!(:user) { create(:user, :admin, :confirmed) }

    let!(:active_step) do
      create(:participatory_process_step, participatory_process:, active: true)
    end
    let(:step) { active_step }

    context "when there's more than one step" do
      let!(:inactive_step) do
        create(:participatory_process_step, participatory_process:, active: false)
      end

      context "when deleting the active step" do
        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid, :active_step)
        end

        it "doesn't delete the step" do
          subject.call
          expect(active_step).to be_persisted
        end
      end

      context "when deleting an inactive step" do
        let(:reorderer) { double(call: true) }
        let(:step) { inactive_step }

        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "delete the step" do
          subject.call
          expect { inactive_step.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(:delete, inactive_step, user)
            .and_call_original

          expect { subject.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
          expect(action_log.version.event).to eq "destroy"
        end

        it "reorders the remaining steps" do
          allow(Admin::ReorderParticipatoryProcessSteps)
            .to receive(:new)
            .with([active_step], [active_step.id])
            .and_return(reorderer)
          expect(reorderer).to receive(:call)

          subject.call
        end
      end
    end

    context "when trying to delete the last step" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end
    end
  end
end

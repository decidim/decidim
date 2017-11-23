# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::DestroyParticipatoryProcessStep, class: true do
    let(:subject) { described_class }

    let!(:participatory_process) { create(:participatory_process) }

    let!(:active_step) do
      create(:participatory_process_step, participatory_process: participatory_process, active: true)
    end

    context "when there's more than one step" do
      let!(:inactive_step) do
        create(:participatory_process_step, participatory_process: participatory_process, active: false)
      end

      context "when destroying the active step" do
        it "broadcasts invalid" do
          expect { subject.call(active_step) }.to broadcast(:invalid, :active_step)
        end

        it "doesn't destroy the step" do
          subject.call(active_step)
          expect(active_step).to be_persisted
        end
      end

      context "when destroying an inactive step" do
        let(:reorderer) { double(call: true) }

        it "broadcasts ok" do
          expect { subject.call(inactive_step) }.to broadcast(:ok)
        end

        it "destroys the step" do
          subject.call(inactive_step)
          expect(inactive_step).not_to be_persisted
        end

        it "reorders the remaining steps" do
          allow(Admin::ReorderParticipatoryProcessSteps)
            .to receive(:new)
            .with([active_step], [active_step.id])
            .and_return(reorderer)
          expect(reorderer).to receive(:call)

          subject.call(inactive_step)
        end
      end
    end

    context "when trying to destroy the last step" do
      it "broadcasts ok" do
        expect { subject.call(active_step) }.to broadcast(:ok)
      end
    end
  end
end

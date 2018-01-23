# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::ActivateParticipatoryProcessStep do
    subject { described_class.new(process_step) }

    let(:process_step) { create :participatory_process_step }
    let(:participatory_process) { process_step.participatory_process }

    context "when the step is nil" do
      let(:process_step) { nil }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the step is active" do
      let(:process_step) { create :participatory_process_step, :active }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the step is not active" do
      let!(:active_step) do
        create :participatory_process_step, :active, participatory_process: participatory_process
      end

      it "is valid" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "activates it" do
        subject.call
        expect(process_step).to be_active
      end

      it "deactivates the process active steps" do
        subject.call
        active_step.reload
        expect(active_step).not_to be_active
      end

      it "notifies the process followers" do
        follower = create(:user, organization: participatory_process.organization)
        create(:follow, followable: participatory_process, user: follower)

        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.participatory_process.step_activated",
            event_class: Decidim::ParticipatoryProcessStepActivatedEvent,
            resource: process_step,
            recipient_ids: [follower.id]
          )

        subject.call
      end
    end
  end
end

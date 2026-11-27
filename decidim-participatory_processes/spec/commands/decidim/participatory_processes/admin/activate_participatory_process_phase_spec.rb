# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::ActivateParticipatoryProcessPhase do
    subject { described_class.new(process_phase, user) }

    let(:user) { create(:user, :admin, :confirmed) }
    let(:process_phase) { create(:participatory_process_phase) }
    let(:participatory_process) { process_phase.participatory_process }

    context "when the phase is nil" do
      let(:process_phase) { nil }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the phase is active" do
      let(:process_phase) { create(:participatory_process_phase, :active) }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the phase is not active" do
      let!(:active_phase) do
        create(:participatory_process_phase, :active, participatory_process:)
      end

      it "is valid" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "activates it" do
        subject.call
        expect(process_phase).to be_active
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:activate, process_phase, user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to be_present
      end

      it "deactivates the process active phases" do
        subject.call
        active_phase.reload
        expect(active_phase).not_to be_active
      end

      it "notifies the process followers" do
        follower = create(:user, organization: participatory_process.organization)
        create(:follow, followable: participatory_process, user: follower)

        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.participatory_process.phase_activated",
            event_class: Decidim::ParticipatoryProcessPhaseActivatedEvent,
            resource: process_phase,
            followers: [follower]
          )

        subject.call
      end

      context "when the process has some components" do
        let!(:component) do
          create(:component, manifest_name: "dummy", participatory_space: participatory_process)
        end

        it "publishes the settings change for each component in the process" do
          expect(Decidim::SettingsChange).to receive(:publish).with(
            component,
            component.phase_settings[active_phase.id.to_s].to_h,
            component.phase_settings[process_phase.id.to_s].to_h
          )

          subject.call
        end
      end
    end
  end
end

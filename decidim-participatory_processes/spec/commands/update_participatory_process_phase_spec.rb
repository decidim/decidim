# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::UpdateParticipatoryProcessPhase do
    subject { described_class.new(form, phase) }

    let(:phase) { create(:participatory_process_phase) }
    let(:user) { create(:user, :admin, :confirmed) }
    let(:participatory_process) { phase.participatory_process }
    let(:form) do
      instance_double(
        Admin::ParticipatoryProcessPhaseForm,
        current_user: user,
        title: { en: "new title" },
        description: { en: "new description" },
        start_date:,
        end_date:,
        invalid?: invalid
      )
    end

    context "when the form is not valid" do
      let(:invalid) { true }
      let(:start_date) { nil }
      let(:end_date) { nil }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      let(:invalid) { false }
      let(:start_date) { phase.start_date }
      let(:end_date) { phase.end_date }

      it "updates a participatory process phase" do
        subject.call
        phase.reload

        expect(phase.title["en"]).to eq("new title")
        expect(phase.description["en"]).to eq("new description")
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "does not notify followers" do
        expect(Decidim::EventsManager).not_to receive(:publish)

        subject.call
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(Decidim::ParticipatoryProcessPhase, user, hash_including(:title, :description, :start_date, :end_date))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "update"
      end

      context "when the dates are updated" do
        let(:start_date) { Date.current }
        let(:end_date) { 1.week.from_now }

        it "notifies the process followers" do
          follower = create(:user, organization: participatory_process.organization)
          create(:follow, followable: participatory_process, user: follower)

          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.participatory_process.phase_changed",
              event_class: Decidim::ParticipatoryProcessPhaseChangedEvent,
              resource: phase,
              followers: [follower]
            )

          subject.call
        end
      end
    end
  end
end

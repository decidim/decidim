# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::CreateParticipatoryProcessPhase do
    subject { described_class.new(form) }

    let(:user) { create(:user, :admin) }
    let(:participatory_process) { create(:participatory_process) }
    let(:form) do
      instance_double(
        Admin::ParticipatoryProcessPhaseForm,
        current_user: user,
        title: { en: "title" },
        description: { en: "description" },
        start_date: Date.current,
        end_date: Date.current + 1.week,
        current_participatory_space: participatory_process,
        invalid?: invalid
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "creates a participatory process phase" do
        expect { subject.call }.to change(Decidim::ParticipatoryProcessPhase, :count).by(1)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(Decidim::ParticipatoryProcessPhase, user, hash_including(:title, :description, :start_date, :end_date, :participatory_process, :active))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      context "when the process has no active phases" do
        it "creates the phase as active" do
          subject.call
          expect(Decidim::ParticipatoryProcessPhase.last).to be_active
        end
      end

      context "when the process has active phases" do
        before do
          create(:participatory_process_phase, participatory_process:, active: true)
        end

        it "creates the phase as active" do
          subject.call
          expect(Decidim::ParticipatoryProcessPhase.last).not_to be_active
        end
      end
    end
  end
end

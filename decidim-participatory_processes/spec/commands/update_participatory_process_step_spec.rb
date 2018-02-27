# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::UpdateParticipatoryProcessStep do
    subject { described_class.new(step, form) }

    let(:step) { create :participatory_process_step }
    let(:participatory_process) { step.participatory_process }
    let(:form) do
      instance_double(
        Admin::ParticipatoryProcessStepForm,
        title: { en: "new title" },
        description: { en: "new description" },
        start_date: start_date,
        end_date: end_date,
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
      let(:start_date) { step.start_date }
      let(:end_date) { step.end_date }

      it "updates a participatory process step" do
        subject.call
        step.reload

        expect(step.title["en"]).to eq("new title")
        expect(step.description["en"]).to eq("new description")
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "doesn't notify followers" do
        expect(Decidim::EventsManager).not_to receive(:publish)

        subject.call
      end

      context "when the dates are updated" do
        let(:start_date) { Time.zone.now }
        let(:end_date) { 1.week.from_now }

        it "notifies the process followers" do
          follower = create(:user, organization: participatory_process.organization)
          create(:follow, followable: participatory_process, user: follower)

          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.participatory_process.step_changed",
              event_class: Decidim::ParticipatoryProcessStepChangedEvent,
              resource: step,
              recipient_ids: [follower.id]
            )

          subject.call
        end
      end
    end
  end
end
